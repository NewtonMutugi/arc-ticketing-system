require "test_helper"

class Admin::VerificationsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    sign_in_as(User.take)
    get admin_verify_attendee_url(token: "test")
    assert_response :not_found
  end
end
