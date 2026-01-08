class DashboardController < ApplicationController
  layout "dashboard"
  def index
    @user = Current.user
  end
end
