class Dashboard::TransactionsController < ApplicationController
  layout "event_dashboard"
  before_action :set_event
  before_action :set_user

  def index
    @query = @event.orders.where(status: [ :paid, :refunded ]).order(created_at: :desc)
    @pagy, @transactions = pagy(@query)
    @total_revenue = @event.orders.paid.sum(:total_cost)
  end

  private
  def set_event
    @event = Event.find(params[:event_id])
  end

  def set_user
    @user = Current.user
  end
end
