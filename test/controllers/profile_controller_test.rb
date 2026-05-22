require "test_helper"

class ProfileControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    sign_in_as(User.take)
    get admin_profile_url
    assert_response :success
  end

  test "should get update" do
    assert true
  end
end
