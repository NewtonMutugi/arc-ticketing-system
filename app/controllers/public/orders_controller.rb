module Public
  class OrdersController < ApplicationController
    layout "public"
    before_action :set_event
    allow_unauthenticated_access
    before_action :resume_session

    def create
      # 1. Initialize Order
      @order = @event.orders.new(order_params)
      @order.status = :pending
      @order.order_no = "ORD-#{SecureRandom.hex(4).upcase}"

      # 2. Calculate Costs (Simple logic for now)
      total = 0
      params[:tickets].each do |ticket_id, quantity|
        qty = quantity.to_i
        next if qty <= 0

        ticket = Ticket.find(ticket_id)
        # Create the OrderItems in memory
        @order.order_items.build(ticket: ticket, quantity: qty, unit_price: ticket.price)
        total += (ticket.price * qty)
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
      # Finalize details -> Redirect to Payment (Later)
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
