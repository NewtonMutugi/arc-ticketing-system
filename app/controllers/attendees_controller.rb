class AttendeesController < ApplicationController
  layout "event_dashboard"
  before_action :set_event
  before_action :set_user

  def index
    @query = @event.attendees.includes(:ticket, :order).order(created_at: :desc)

    if params[:query].present?
      @query = @query.where("first_name ILIKE ? OR last_name ILIKE ? OR email ILIKE ? OR token ILIKE ?",
                    "%#{params[:query]}%", "%#{params[:query]}%", "%#{params[:query]}%", "%#{params[:query]}%")
    end

    @pagy, @attendees = pagy(@query)
  end


  private

  def set_event
    @event = Event.find(params[:event_id])
  end

  def set_user
    @user = Current.user
  end
end
