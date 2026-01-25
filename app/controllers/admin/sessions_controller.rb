class Admin::SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_admin_session_path, alert: "Try again later." }
  layout "public"

  before_action :resume_session, only: %i[ new create ]

  before_action :redirect_if_authenticated, only: %i[ new create ]

  def new
  end

  def create
    if user = User.authenticate_by(params.permit(:email_address, :password))
      start_new_session_for user
      redirect_to admin_root_path
    else
      redirect_to new_admin_session_path, alert: "Try another email address or password."
    end
  end

  def destroy
    terminate_session
    redirect_to root_path, status: :see_other
  end

  private

  def redirect_if_authenticated
    if Current.user
      redirect_to admin_events_path, notice: "You are already signed in."
    end
  end
end
