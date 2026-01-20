class TicketsController < ApplicationController
  layout "event_dashboard"
  before_action :set_event

  before_action :set_user
  def index
    @tickets = @event.tickets
  end

  def show
  end


  def destroy
  end

  def new
    @ticket = @event.tickets.new
  end

  def create
    @ticket = @event.tickets.new(ticket_params)
    if @ticket.save
      redirect_to event_tickets_path(@event), notice: "Ticket created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @ticket = @event.tickets.find(params[:id])
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to events_path, alert: "Event not found"
  end

  def ticket_params
    params.require(:ticket).permit(:title, :price, :quantity, :start_sale_date, :end_sale_date, :description)
  end

  def set_user
    @user = Current.user
  end
end
