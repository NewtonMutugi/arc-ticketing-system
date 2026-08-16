class Admin::AttendeesController < Admin::BaseController
  layout "event_dashboard"
  before_action :set_event
  before_action :set_user
  before_action :set_attendee, only: [:edit, :update, :resend_ticket]

  def index
    @query = @event.attendees.joins(:order).where(orders: { status: "paid" }).includes(:ticket, :order).order(created_at: :desc)
    if params[:query].present?
      @query = @query.where("first_name ILIKE ? OR last_name ILIKE ? OR email ILIKE ? OR token ILIKE ?",
                    "%#{params[:query]}%", "%#{params[:query]}%", "%#{params[:query]}%", "%#{params[:query]}%")
    end
    @pagy, @attendees = pagy(@query)
  end

  def edit
  end

  def update
    if @attendee.update(attendee_params)
      # Redirect back to the return_to path or order show page
      redirect_to params[:return_to].presence || admin_event_order_path(@event, @attendee.order), notice: "Attendee details updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def resend_ticket
    OrderMailer.attendee_ticket_email(@attendee).deliver_later
    redirect_to admin_event_order_path(@event, @attendee.order), notice: "Ticket resent to #{@attendee.email} successfully."
  end

  private
  def set_event
    @event = Event.friendly.find(params[:event_id])
  end

  def set_user
    @user = Current.user
  end

  def set_attendee
    @attendee = @event.attendees.find(params[:id])
  end

  def attendee_params
    params.require(:attendee).permit(:first_name, :last_name, :preferred_name, :email)
  end
end
