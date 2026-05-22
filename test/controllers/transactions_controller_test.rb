require "test_helper"

class TransactionsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    sign_in_as(User.take)
    get admin_event_transactions_url(Event.take || events(:one))
    assert_response :success
  end
end
