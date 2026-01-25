class Admin::OrdersController < Admin::BaseController
  layout "event_dashboard"
  before_action :set_event
  before_action :set_order, only: [ :show, :approve ]

  def index
    @query = @event.orders.includes(:order_items).order(created_at: :desc)
    @pagy, @orders = pagy(@query)
  end

  def show
  end

  def approve
    if @order.update(status: :paid)
      # TODO: Trigger Email Delivery - change to deliver later
      OrderMailer.confirmation_email(@order).deliver_now

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

  private

  def set_event
    @event = Event.find(params[:event_id])
  end

  def set_order
    @order = @event.orders.find(params[:id])
  end
end
