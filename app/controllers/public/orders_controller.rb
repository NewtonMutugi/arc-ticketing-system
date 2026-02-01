module Public
  class OrdersController < ApplicationController
    layout "public"
    before_action :set_event
    allow_unauthenticated_access
    before_action :resume_session

    before_action :set_order, only: [ :attendees, :confirm, :checkout, :pay, :show ]

    def create
      # Check if any tickets were actually selected
      total_qty = params[:tickets]&.values&.map(&:to_i)&.sum || 0

      if total_qty <= 0
        redirect_to event_path(@event, order_no: params[:order_no]),
                    alert: "Please select at least one ticket."
        return
      end

      # Initialize Order or find order to resume
      if params[:order_no].present?
        @order = Order.find_by!(order_no: params[:order_no])
        @order.assign_attributes(order_params)
        @order.order_items.destroy_all # Clear items to rebuild from current selection
      else
        @order = Order.new(order_params)
        @order.status = :pending
        @order.order_no = "ORD-#{SecureRandom.hex(4).upcase}"
      end

      # Calculate Costs and items
      total = 0
      if params[:tickets]
        params[:tickets].each do |ticket_id, quantity|
          qty = quantity.to_i
          next if qty <= 0

          ticket = Ticket.find(ticket_id)
          # Create the OrderItems in memory
          @order.order_items.build(ticket: ticket, quantity: qty, unit_price: ticket.price)
          total += (ticket.price * qty)
        end
      end

      @order.total_cost = total
      @order.total_items = @order.order_items.sum(&:quantity)

      if @order.save
        # Redirect to Step 2: Attendee Details
        redirect_to event_order_attendees_path(@event, @order)
      else
        redirect_to event_path(@event), alert: "Could not start order."
      end
    end

    def attendees
      # Logic to display form for @order.total_items attendees
    end

    def confirm
      # Transaction ensures we save all attendees or none
      ActiveRecord::Base.transaction do
        # Clear existing attendees for this order to avoid duplicates on "Back/Forward"
        @order.attendees.destroy_all

        params[:attendees].each do |attendee_data|
          # Create the attendee linked to Event, Ticket, and Order
          @order.attendees.create!(
            event: @event,
            ticket_id: attendee_data[:ticket_id],
            first_name: attendee_data[:first_name],
            last_name: attendee_data[:last_name],
            email: attendee_data[:email],
            token: SecureRandom.hex(10).upcase # Unique ticket code
          )
        end
      end

      # For now, since we don't have payment, we redirect to a success page
      # redirect_to event_order_path(@event, @order), notice: "Order confirmed!"
      redirect_to event_order_checkout_path(@event, @order), notice: "Attendees saved. Please verify payment."

    rescue ActiveRecord::RecordInvalid
      redirect_to event_order_attendees_path(@event, @order), alert: "Please check attendee details."
    end

    # Add a simple show page for the "Success" state
    def show
    end

    def checkout
    end

    def pay
      if @order.update(payment_params)
        # TODO: Send Email - deliver now
        OrderMailer.receipt_email(@order).deliver_now

        # We keep status as 'pending' but now it has a reference number for Admin to check
        redirect_to event_order_path(@event, @order), notice: "Payment details submitted for review!"
      else
        render :checkout, status: :unprocessable_entity
      end
    end

    private

    def set_order
      identifier = params[:order_no] || params[:order_order_no] || params[:id]
      @order = Order.find_by!(order_no: identifier)
    end

    def set_event
      @event = Event.friendly.find(params[:event_id])
    end

    def order_params
      params.permit(:buyer_name, :buyer_email, :buyer_phone_no)
    end

    def payment_params
      params.require(:order).permit(:payment_provider, :payment_reference)
    end
  end
end
