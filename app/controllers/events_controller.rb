class EventsController < ApplicationController
  layout :resolve_layout
  before_action :set_user

  before_action :set_event, only: %i[ show edit update destroy ]
  def index
    @events = Event.all.with_attached_event_image
  end

  def show
    @tickets = Ticket.all
    @orders = Order.all
    @event
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

  def edit
  end

  def update
  end

  def destroy
  end

  private
  def set_user
    @user = Current.user
  end

  def set_event
    @event = Event.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to events_path, alert: "Event not found."
  end

  def resolve_layout
    case action_name
    when "show"
      "event_dashboard"
    else
      "dashboard"
    end
  end

  def event_params
    params.expect(event: [ :title, :start_date, :end_date, :location, :description, :event_image ])
  end
end
