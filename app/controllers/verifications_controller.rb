class VerificationsController < ApplicationController
  allow_unauthenticated_access

  def show
    @attendee = Attendee.find_by!(token: params[:token])
    @event = @attendee.event

    if authenticated?
      # Admin Flow
      today = Date.current

      if today < @event.start_date || today > @event.end_date
        @status = :outside_event_dates
        flash.now[:alert] = "ERROR! Today's date (#{today}) is outside the event dates (#{@event.start_date} to #{@event.end_date})."
      elsif @attendee.checked_in?(today)
        @status = :already_checked_in
        flash.now[:alert] = "ALREADY SCANNED! Checked in for today."
      else
        @attendee.check_ins.create!(date: today)
        @status = :success
        flash.now[:notice] = "SUCCESS! #{@attendee.first_name} is now checked in for today."
      end

      render "admin_show"
    else
      # Public Flow
      render "public", layout: "application"
    end
  end
end
