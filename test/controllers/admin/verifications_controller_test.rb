require "test_helper"

class Admin::VerificationsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get admin_verifications_show_url
    assert_response :success
  end
end
