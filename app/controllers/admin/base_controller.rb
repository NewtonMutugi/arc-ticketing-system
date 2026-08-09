class Admin::BaseController < ApplicationController
  include Pundit::Authorization

  layout :resolve_layout
  before_action :set_user
  before_action :authenticate_user!

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def pundit_user
    Current.user
  end

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_back fallback_location: admin_root_path
  end

  def authenticate_user!
      if Current.user.nil?
        redirect_to admin_new_session_path, alert: "Please sign in to access the dashboard."
      end
  end

  def set_user
    @user = Current.user
  end

  def resolve_layout
    case action_name
    when "show", "edit", "update"
      "event_dashboard"
    else
      "dashboard"
    end
  end
end
