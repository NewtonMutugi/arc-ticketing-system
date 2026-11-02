class Admin::TicketUpgradesController < Admin::BaseController
  layout false
  before_action :set_event
  before_action :set_attendee

  def new
    authorize @attendee, :update?
    @available_tickets = @event.tickets.where("price > ?", @attendee.ticket.price)
    @ticket_upgrade = TicketUpgrade.new
  end

  def create
    authorize @attendee, :update?

    from_ticket = @attendee.ticket
    to_ticket = @event.tickets.find(params[:ticket_upgrade][:to_ticket_id])
    amount_paid = [ to_ticket.price - from_ticket.price, 0 ].max
    payment_method = params[:payment_method]

    @ticket_upgrade = TicketUpgrade.new(
      attendee: @attendee,
      from_ticket: from_ticket,
      to_ticket: to_ticket,
      upgraded_by_user: Current.user,
      amount_paid: amount_paid
    )

    if payment_method == "stk_push"
      @ticket_upgrade.status = :pending
      @ticket_upgrade.payment_provider = "Mpesa"

      if @ticket_upgrade.save
        phone_number = params[:phone_number].presence || @attendee.order.buyer_phone_no
        mpesa = MpesaService.new(@ticket_upgrade)
        result = mpesa.stk_push(phone_number)

        if result["ResponseCode"] == "0"
          @ticket_upgrade.update!(checkout_request_id: result["CheckoutRequestID"])
          redirect_to admin_event_order_path(@event, @attendee.order), notice: "STK push sent to #{phone_number}. Upgrade will complete once paid."
        else
          @ticket_upgrade.update!(status: :failed)
          redirect_to admin_event_order_path(@event, @attendee.order), alert: "STK push failed: #{result["CustomerMessage"]}"
        end
      else
        redirect_to admin_event_order_path(@event, @attendee.order), alert: "Could not create upgrade record."
      end
    else
      # Manual/Reference
      @ticket_upgrade.status = :paid
      @ticket_upgrade.payment_provider = params[:payment_provider].presence || "Manual"
      @ticket_upgrade.payment_reference = params[:payment_reference].presence || "N/A"

      if @ticket_upgrade.save
        @ticket_upgrade.apply_upgrade!
        redirect_to admin_event_order_path(@event, @attendee.order), notice: "Ticket successfully upgraded to #{to_ticket.title}."
      else
        redirect_to admin_event_order_path(@event, @attendee.order), alert: "Could not complete upgrade."
      end
    end
  end

  private

  def set_event
    @event = Event.friendly.find(params[:event_id])
  end

  def set_attendee
    @attendee = @event.attendees.find(params[:attendee_id])
  end
end
