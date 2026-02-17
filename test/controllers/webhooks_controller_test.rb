require "test_helper"

class WebhooksControllerTest < ActionDispatch::IntegrationTest
  test "should get mpesa" do
    get webhooks_mpesa_url
    assert_response :success
  end
end
