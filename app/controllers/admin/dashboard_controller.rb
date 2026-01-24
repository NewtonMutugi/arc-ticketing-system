class Admin::DashboardController < Admin::BaseController
  layout "dashboard"
  def index
    @user = Current.user
    @events = Event.count
    @tickets_sold = Event.all.sum(&:tickets_sold)
    @revenue = Event.all.sum(&:revenue)
  end
end
