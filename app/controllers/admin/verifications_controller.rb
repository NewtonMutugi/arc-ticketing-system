class Admin::VerificationsController < Admin::BaseController
  before_action :authenticate_user!
  def show
    @attendee = Attendee.find_by!(token: params[:token])
    @event = @attendee.event

    # Check if already checked in
    if @attendee.checked_in_at.present?
      @status = :already_checked_in
      flash.now[:alert] = "ALREADY SCANNED! Checked in at #{@attendee.checked_in_at.strftime('%H:%M')}"
    else
      # Mark as present
      @attendee.update!(checked_in_at: Time.current)
      @status = :success
      flash.now[:notice] = "SUCCESS! #{@attendee.first_name} is now checked in."
    end
  end
end
