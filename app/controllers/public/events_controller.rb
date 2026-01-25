module Public
  class EventsController < ApplicationController
    layout "public"
    allow_unauthenticated_access

    before_action :resume_session

    # Landing Page
    def index
      @events = Event.where(publish: true).where("end_date >= ?", Date.today)
    end

    # The "Buy Tickets" Page
    def show
      @event = Event.friendly.find(params[:id])
      # Only show tickets that are active and active sale dates
      @tickets = @event.tickets.where(status: true)
                               .where("start_sale_date <= ? AND end_sale_date >= ?", Date.today, Date.today)
    end
  end
end
