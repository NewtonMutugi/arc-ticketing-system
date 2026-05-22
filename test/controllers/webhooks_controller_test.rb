require "test_helper"

class WebhooksControllerTest < ActionDispatch::IntegrationTest
  test "should get mpesa" do
    post webhooks_mpesa_url, params: { Body: { stkCallback: { ResultCode: 1, CheckoutRequestID: "123" } } }
    assert_response :not_found
  end
end
