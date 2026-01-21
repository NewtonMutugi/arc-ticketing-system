class Admin::DashboardController < Admin::BaseController
  layout "dashboard"
  def index
    @user = Current.user
    @events = Event.all
    @tickets = Ticket.all
    @revenue = Ticket.sum(:price)
  end
end
