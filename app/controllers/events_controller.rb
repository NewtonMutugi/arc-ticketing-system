class EventsController < ApplicationController
  layout "dashboard"
  before_action :set_user
  def index
    @events = Event.all
  end

  def show
  end

  def new
    @event = Event.new
  end

  def create
    @event = Event.new(event_params)
    if @event.save
      redirect_to events_path, status: :see_other, notice: "Event created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
  def set_user
    @user = Current.user
  end

  def event_params
    params.expect(event: [ :name, :date, :time, :location, :description, :image_tag ])
  end
end
