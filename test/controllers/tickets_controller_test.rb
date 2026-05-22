require "test_helper"

class TicketsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    sign_in_as(User.take)
    get admin_event_tickets_url(Event.take || events(:one))
    assert_response :success
  end
end
