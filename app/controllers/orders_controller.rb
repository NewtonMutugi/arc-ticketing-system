class OrdersController < ApplicationController
  layout "event_dashboard"
  before_action :set_event
  before_action :set_user
  def index
    @query = @event.orders.includes(:order_items).order(created_at: :desc)
    @pagy, @orders = pagy(@query)
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end

  def set_user
    @user = Current.user
  end
end
