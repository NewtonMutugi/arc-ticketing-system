class Admin::OrdersController < Admin::BaseController
  layout "event_dashboard"
  before_action :set_event
  before_action :set_order, only: [ :show, :approve, :resend_confirmation_email, :reject_payment ]

  def index
    @query = @event.orders.includes(:order_items).order(created_at: :desc)
    @pagy, @orders = pagy(@query)
  end

  def show
  end

  def approve
    if @order.update(status: :paid, approved_by_user_id: Current.user.id, approved_at: Time.current)
      OrderMailer.confirmation_email(@order).deliver_later

      respond_to do |format|
        format.html { redirect_to admin_event_orders_path(@event), notice: "Order approved." }

        format.turbo_stream do
          render turbo_stream: [
            # 1. Update the row in the background list to show 'Paid'
            turbo_stream.replace("order_row_#{@order.id}", partial: "admin/orders/order_row", locals: { order: @order, event: @event }),

            # 2. Close the modal
            turbo_stream.update("modal", ""),

            # 3. Show Success Toast
            turbo_stream.append("flash-toasts", partial: "shared/flash_toast", locals: { type: :success, title: "Approved", body: "Order ##{@order.order_no} verified." })
          ]
        end
      end
    else
      redirect_to admin_event_order_path(@event, @order), alert: "Approval failed."
    end
  end

  def resend_confirmation_email
    if @order.paid?
      OrderMailer.confirmation_email(@order).deliver_later

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
end
