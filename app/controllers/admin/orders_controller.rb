class Admin::OrdersController < Admin::BaseController
  layout "event_dashboard"
  before_action :set_event
  before_action :set_order, only: [ :show, :approve, :resend_confirmation_email, :reject_payment ]

  def index
    authorize Order
    @query = @event.orders.includes(:order_items).order(created_at: :desc)
    
    if params[:query].present?
      @query = @query.where("order_no ILIKE ? OR buyer_name ILIKE ? OR buyer_email ILIKE ?",
                    "%#{params[:query]}%", "%#{params[:query]}%", "%#{params[:query]}%")
    end

    @pagy, @orders = pagy(@query)
  end

  def new
    @order = Order.new
    @tickets = @event.tickets
    authorize @order
  end

  def create
    @order = Order.new(order_params)
    authorize @order

    ticket_id_param = params[:order][:ticket_id]
    ticket = @event.tickets.find(Ticket.decode_id(ticket_id_param) || ticket_id_param)
    quantity = params[:order][:quantity].to_i

    # Use override cost if provided, otherwise calculate
    override_cost = params[:order][:total_cost]
    if override_cost.present?
      @order.total_cost = override_cost.to_d
      unit_price = override_cost.to_d / quantity
    else
      @order.total_cost = ticket.price * quantity
      unit_price = ticket.price
    end

    @order.order_items.build(ticket: ticket, quantity: quantity, unit_price: unit_price)
    @order.total_items = quantity

    # If the admin creates it directly as paid, mark it approved
    if @order.paid?
      @order.approved_by_user_id = Current.user.id
      @order.approved_at = Time.current
    end

    if @order.save
      if params[:attendees].present?
        params[:attendees].each do |attendee_params|
          @order.attendees.create!(
            event: @event,
            ticket: ticket,
            email: attendee_params[:email],
            first_name: attendee_params[:first_name],
            last_name: attendee_params[:last_name],
            token: SecureRandom.hex(6).upcase
          )
        end
      elsif @order.paid?
        # Fallback if no attendees provided but status is paid
        @order.send(:generate_attendees)
      end

      if @order.paid?
        @order.send_confirmation_emails!
      elsif @order.submitted?
        OrderMailer.receipt_email(@order).deliver_later
      end

      respond_to do |format|
        format.html { redirect_to admin_event_orders_path(@event), notice: "Order created successfully." }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.prepend("orders_list", partial: "admin/orders/order_row", locals: { order: @order, event: @event }),
            turbo_stream.update("modal", ""),
            turbo_stream.append("flash-toasts", partial: "shared/flash_toast", locals: { type: :success, title: "Order Created", body: "Order ##{@order.order_no} created." })
          ]
        end
      end
    else
      @tickets = @event.tickets
      render :new, status: :unprocessable_entity
    end
  end

  def show
    authorize @order if defined?(@order)
  end

  def approve
    authorize @order
    if @order.update(status: :paid, approved_by_user_id: Current.user.id, approved_at: Time.current)
      @order.send_confirmation_emails!

      respond_to do |format|
        format.html { redirect_to admin_event_orders_path(@event), notice: "Order approved." }

        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("order_row_#{@order.id}", partial: "admin/orders/order_row", locals: { order: @order, event: @event }),

            turbo_stream.update("modal", ""),

            turbo_stream.append("flash-toasts", partial: "shared/flash_toast", locals: { type: :success, title: "Approved", body: "Order ##{@order.order_no} verified." })
          ]
        end
      end
    else
      redirect_to admin_event_order_path(@event, @order), alert: "Approval failed."
    end
  end

  def resend_confirmation_email
    authorize @order
    if @order.paid?
      @order.send_confirmation_emails!

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.append("flash-toasts", partial: "shared/flash_toast", locals: { type: :success, title: "Confirmation queued", body: "Confirmation email for order ##{@order.order_no} has been queued." })
        end
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.append("flash-toasts", partial: "shared/flash_toast", locals: { type: :error, title: "Error", body: "Can only resend confirmation for paid orders." })
        end
      end
    end
  end

  def reject_payment
    authorize @order
    if @order.update(status: :failed, approved_by_user_id: Current.user.id, approval_notes: params[:rejection_reason])
      # Send rejection email to customer
      OrderMailer.rejection_email(@order).deliver_later

      respond_to do |format|
        format.html { redirect_to admin_event_orders_path(@event), notice: "Payment rejected." }

        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("order_row_#{@order.id}", partial: "admin/orders/order_row", locals: { order: @order, event: @event }),
            turbo_stream.replace("modal", template: "admin/orders/show"),
            turbo_stream.append("flash-toasts", partial: "shared/flash_toast", locals: { type: :success, title: "Rejected", body: "Payment for order ##{@order.order_no} has been rejected." })
          ]
        end
      end
    else
      redirect_to admin_event_order_path(@event, @order), alert: "Rejecting payment failed."
    end
  end

  # USED FOR TESTING PURPOSES ONLY
  # def disapprove
  #   @order = @event.orders.find(params[:id])
  #   if @order.update(status: :pending)
  #     respond_to do |format|
  #       format.html { redirect_to admin_event_orders_path(@event), notice: "Order disapproved." }

  #       format.turbo_stream do
  #         render turbo_stream: [
  #           turbo_stream.replace("order_row_#{@order.id}", partial: "admin/orders/order_row", locals: { order: @order, event: @event }),
  #           turbo_stream.replace("modal", template: "admin/orders/show"),
  #           turbo_stream.append("flash-toasts", partial: "shared/flash_toast", locals: { type: :warning, title: "Disapproved", body: "Order payment marked as pending." })
  #         ]
  #       end
  #     end
  #   else
  #     redirect_to admin_event_order_path(@event, @order), alert: "Disapproval failed."
  #   end
  # end

  private

  def set_event
    @event = Event.friendly.find(params[:event_id])
  end

  def set_order
    identifier = params[:order_no] || params[:order_order_no] || params[:id]
    @order = @event.orders.find_by!(order_no: identifier)
  end

  def order_params
    params.require(:order).permit(:buyer_name, :buyer_email, :buyer_phone_no, :status, :payment_provider, :payment_reference)
  end
end
