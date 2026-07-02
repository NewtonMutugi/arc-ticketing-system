class Admin::EventsController < Admin::BaseController
  before_action :set_event, only: %i[ show edit update destroy ]

  def index
    authorize Event
    @events = Event.all.with_attached_event_image
    @tickets_sold = Event.all.sum(&:tickets_sold)
    @revenue = Event.all.sum(&:revenue)
  end

  def show
    authorize @event
    @orders = @event.total_order_count
    @tickets_sold = @event.tickets_sold
    @revenue = @event.revenue
  end

  def new
    authorize Event
    @event = Event.new
  end

  def create
    authorize Event
    @event = Event.new(event_params)
    @event.created_by_user_id = Current.user.id
    if @event.save
      redirect_to admin_events_path, status: :see_other, notice: "Event created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @event
    @event
  end

  def update
    authorize @event
    if @event.update(event_params)
      redirect_to admin_event_path(@event), notice: "Event details updated"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @event
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
