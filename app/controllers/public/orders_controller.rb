module Public
  class OrdersController < ApplicationController
    layout "public"
    before_action :set_event
    allow_unauthenticated_access
    before_action :resume_session

    def create
      # 1. Initialize Order
      @order = Order.new(order_params)
      @order.status = :pending

      @order.order_no = "ORD-#{SecureRandom.hex(4).upcase}"

      # 2. Calculate Costs (Simple logic for now)
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
      @order = Order.find(params[:order_id])
      # Logic to display form for @order.total_items attendees
    end

    def confirm
      @order = Order.find(params[:order_id])

      # Transaction ensures we save all attendees or none
      ActiveRecord::Base.transaction do
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
      redirect_to event_order_path(@event, @order), notice: "Order confirmed!"

    rescue ActiveRecord::RecordInvalid => e
      redirect_to event_order_attendees_path(@event, @order), alert: "Please check attendee details."
    end

    # Add a simple show page for the "Success" state
    def show
      @order = Order.find(params[:id])
    end

    private

    def set_event
      @event = Event.find(params[:event_id])
    end

    def order_params
      params.permit(:buyer_name, :buyer_email, :buyer_phone_no)
    end
  end
end
