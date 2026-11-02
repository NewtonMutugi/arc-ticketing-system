class Admin::TransactionsController < Admin::BaseController
  layout "event_dashboard"
  before_action :set_event

  def index
    @query = @event.transactions.includes(:referenceable).order(created_at: :desc)
    @pagy, @transactions = pagy(@query)
    @total_revenue = @event.revenue
  end

  private
  def set_event
    @event = Event.friendly.find(params[:event_id])
  end
end
