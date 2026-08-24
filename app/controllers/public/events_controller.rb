module Public
  class EventsController < ApplicationController
    layout "public"
    allow_unauthenticated_access

    before_action :resume_session

    # Landing Page
    def index
      @upcoming_events = Event.published.upcoming.order(start_date: :asc)
      @past_events = Event.published.past.order(start_date: :desc).limit(6)
    end

    # The "Buy Tickets" Page
    def show
      @event = Event.friendly.find(params[:id])
      # Only show tickets that are active and active sale dates
      @tickets = @event.tickets.where(status: true)
                               .where("start_sale_date <= ? AND end_sale_date >= ?", Date.today, Date.today)

      # Check if there is an existing order ID in the URL/params to resume
      @order = Order.find_by(order_no: params[:order_no]) if params[:order_no].present?
    end
  end
end
