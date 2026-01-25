class Admin::EventsController < Admin::BaseController
  before_action :set_event, only: %i[ show edit update destroy ]

  def index
    @events = Event.all.with_attached_event_image
    @tickets_sold = Event.all.sum(&:tickets_sold)
    @revenue = Event.all.sum(&:revenue)
  end

  def show
    @orders = @event.total_order_count
    @tickets_sold = @event.tickets_sold
    @revenue = @event.revenue
  end

  def new
    @event = Event.new
  end

  def create
    @event = Event.new(event_params)
    if @event.save
      redirect_to admin_events_path, status: :see_other, notice: "Event created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @event
  end

  def update
    if @event.update(event_params)
      redirect_to admin_event_path(@event), notice: "Event details updated"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
  end

  private

  def event_params
    params.expect(event: [ :title, :start_date, :end_date, :location, :description, :event_image, :publish ])
  end

  def set_event
    @event = Event.friendly.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to admin_events_path, alert: "Event not found."
  end
end
