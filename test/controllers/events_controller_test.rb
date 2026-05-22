require "test_helper"

class EventsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    sign_in_as(User.take)
    get admin_events_url
    assert_response :success
  end
end
