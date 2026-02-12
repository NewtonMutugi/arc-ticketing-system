class Admin::BaseController < ApplicationController
  layout :resolve_layout
  before_action :set_user
  before_action :authenticate_user!

  private

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
