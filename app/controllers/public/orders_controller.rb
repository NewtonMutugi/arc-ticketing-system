module Public
  class OrdersController < ApplicationController
    layout "public"
    before_action :set_event
    allow_unauthenticated_access
    before_action :resume_session

    before_action :set_order, only: [ :attendees, :confirm, :checkout, :pay, :show, :status ]

    def new
      @ticket = @event.tickets.find(params[:ticket_id])

      if params[:order_no].present?
        @order = Order.find_by(order_no: params[:order_no])

        existing_item = @order.order_items.find_by(ticket: @ticket)
        @quantity = existing_item&.quantity || 1
      else
        @order = Order.new
        @quantity = 1
      end
    end

    def create
      # Check if any tickets were actually selected
      total_qty = params[:tickets]&.values&.map(&:to_i)&.sum || 0

      if total_qty <= 0
        redirect_to new_event_order_path(@event, ticket_id: params[:tickets].keys.first),
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
        @order.status = :draft
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

      redirect_to event_order_checkout_path(@event, @order), notice: "Attendees saved. Please verify payment."

    rescue ActiveRecord::RecordInvalid
      redirect_to event_order_attendees_path(@event, @order), alert: "Please check attendee details."
    end

    def show
    end

    def checkout
    end

    def pay
      # 1. Handle M-PESA STK Push
      if params[:payment_method] == "mpesa"
        if Setting.mpesa_mode == "automated"
          phone = params[:mpesa_phone_number].presence || @order.buyer_phone_no

          begin
            response = MpesaService.new(@order).stk_push(phone)

            if response && response["ResponseCode"] == "0"
              @order.update(
                checkout_request_id: response["CheckoutRequestID"],
                merchant_request_id: response["MerchantRequestID"],
                status: :submitted,
                payment_provider: "Mpesa"
              )
              redirect_to event_order_path(@event, @order), notice: "STK Push sent to #{phone}. Check your phone!"
            else
              message = response&.dig("CustomerMessage").presence || "M-Pesa is temporarily unavailable. Please try again."
              respond_to do |format|
                format.html { redirect_to event_order_checkout_path(@event, @order), alert: message }
                format.turbo_stream do
                  render turbo_stream: turbo_stream.append("flash-toasts", ToastComponent.new(type: :error, title: "Payment Issue", body: message))
                end
              end
            end
          rescue StandardError => e
            Rails.logger.error("MPESA CONTROLLER ERROR: #{e.message}")
            message = e.message
            respond_to do |format|
              format.html { redirect_to event_order_checkout_path(@event, @order), alert: message }
              format.turbo_stream do
                render turbo_stream: turbo_stream.append("flash-toasts", ToastComponent.new(type: :error, title: "Connection Error", body: message))
              end
            end
          end
        else
          respond_to do |format|
            format.html { redirect_to event_order_checkout_path(@event, @order), alert: "Automated M-PESA is currently disabled." }
            format.turbo_stream do
              render turbo_stream: turbo_stream.append("flash-toasts", ToastComponent.new(type: :error, title: "Payment Issue", body: "Automated M-PESA is currently disabled."))
            end
          end
        end
        return
      end

      # 2. Handle Manual Reference Code (Old/Fallback method)
      if params[:order].present?
        if @order.update(payment_params.merge(status: :submitted))
          OrderMailer.receipt_email(@order).deliver_later
          redirect_to event_order_path(@event, @order), notice: "Payment details submitted for review!"

        else
          # render :checkout, status: :unprocessable_entity
          respond_to do |format|
            format.html { render :checkout, status: :unprocessable_entity }
            format.turbo_stream do
              render turbo_stream: turbo_stream.append("flash-toasts", ToastComponent.new(type: :error, title: "Submission Failed", body: "Please check your payment details and try again."))
            end
          end
        end
      else
        # redirect_to event_order_checkout_path(@event, @order), alert: "Please select a valid payment method."
        respond_to do |format|
          format.html { redirect_to event_order_checkout_path(@event, @order), alert: "Please select a valid payment method." }
          format.turbo_stream do
            render turbo_stream: turbo_stream.append("flash-toasts", ToastComponent.new(type: :error, title: "Payment Method Error", body: "Please select a valid payment method."))
            end
          end
      end
    end

    def status
      render json: { status: @order.status }
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
