class Admin::CheckInsController < Admin::BaseController
  layout "event_dashboard"
  before_action :set_event
  before_action :set_user

  def index
    authorize :check_in, :index?
    # Determine which day's tab we are on
    @selected_date = params[:date].present? ? Date.parse(params[:date]) : @event.start_date
    @selected_date = @event.start_date if @selected_date < @event.start_date
    @selected_date = @event.end_date if @selected_date > @event.end_date

    # Generate an array of all event dates for the tabs
    @event_dates = (@event.start_date..@event.end_date).to_a

    # Base scope for valid attendees
    base_attendees = @event.attendees.joins(:order).where(orders: { status: "paid" })

    # Calculate stats for the selected date
    @total_attendees_count = base_attendees.count
    @total_checked_in_count = CheckIn.where(attendee_id: base_attendees.select(:id), date: @selected_date).count
    @total_not_checked_in_count = @total_attendees_count - @total_checked_in_count

    # Fetch attendees for this event (similar to attendees index but without the paid constraint if check-ins are allowed for all, but let's restrict to paid orders just in case, though usually attendees index does it)
    @query = base_attendees.includes(:ticket, :order)
    if params[:query].present?
      @query = @query.where("first_name ILIKE ? OR last_name ILIKE ? OR email ILIKE ? OR token ILIKE ?",
                    "%#{params[:query]}%", "%#{params[:query]}%", "%#{params[:query]}%", "%#{params[:query]}%")
    end

    @pagy, @attendees = pagy(@query)

    # Pre-fetch check-ins for the selected date to optimize N+1
    @check_ins_for_date = CheckIn.where(attendee_id: @attendees.map(&:id), date: @selected_date).index_by(&:attendee_id)
  end

  def create
    authorize :check_in, :create?
    @attendee = @event.attendees.find(params[:attendee_id])
    date = Date.parse(params[:date])

    if @attendee.check_ins.create(date: date)
      redirect_back fallback_location: admin_event_check_ins_path(@event, date: date), notice: "#{@attendee.first_name} checked in for #{date}."
    else
      redirect_back fallback_location: admin_event_check_ins_path(@event, date: date), alert: "Check-in failed: #{@attendee.check_ins.last.errors.full_messages.to_sentence}"
    end
  end

  def destroy
    authorize :check_in, :destroy?
    @attendee = @event.attendees.find(params[:attendee_id])
    date = Date.parse(params[:id])
    check_in = @attendee.check_ins.find_by!(date: date)

    check_in.destroy
    redirect_back fallback_location: admin_event_check_ins_path(@event, date: date), notice: "Check-in for #{@attendee.first_name} on #{date} was removed."
  end

  private

  def set_event
    @event = Event.friendly.find(params[:event_id])
  end

  def set_user
    @user = Current.user
  end
end
