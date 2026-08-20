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

    respond_to do |format|
      format.html do
        @pagy, @attendees = pagy(@query)
      end
      format.csv do
        require 'csv'
        csv_data = CSV.generate(headers: true) do |csv|
          csv << ["First Name", "Last Name", "Email", "Ticket Type", "Order No"]
          @query.each do |attendee|
            csv << [attendee.first_name, attendee.last_name, attendee.email, attendee.ticket.title, "\##{attendee.order.order_no}"]
          end
        end
        send_data csv_data, filename: "attendees-#{@event.title.parameterize}-#{Date.today}.csv"
      end
      format.xlsx do
        @attendees_export = @query
        response.headers['Content-Disposition'] = "attachment; filename=\"attendees-#{@event.title.parameterize}-#{Date.today}.xlsx\""
      end
      format.pdf do
        pdf = AttendeesPdfGenerator.new(@event, @query).render
        send_data pdf, filename: "attendees-#{@event.title.parameterize}-#{Date.today}.pdf", type: "application/pdf", disposition: "attachment"
      end
    end
  end

  def edit
  end

  def update
    old_ticket = @attendee.ticket

    @attendee.assign_attributes(attendee_params)
    ticket_changed = @attendee.ticket_id_changed?

    if ticket_changed
      @attendee.token = SecureRandom.hex(10).upcase
    end

    if @attendee.save
      if ticket_changed
        OrderMailer.ticket_change_email(@attendee, old_ticket).deliver_later
      end
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
    params.require(:attendee).permit(:first_name, :last_name, :preferred_name, :email, :ticket_id)
  end
end
