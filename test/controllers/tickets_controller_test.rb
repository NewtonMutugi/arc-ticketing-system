require "test_helper"

class TicketsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.take
    @ticket = Ticket.first
    @event = @ticket.event
  end

  test "should get index" do
    sign_in_as(@user)
    get admin_event_tickets_url(@event)
    assert_response :success
  end

  test "should get edit using hashid" do
    sign_in_as(@user)
    get edit_admin_event_ticket_url(@event, @ticket)
    assert_response :success
  end

  test "should update ticket using hashid" do
    sign_in_as(@user)
    patch admin_event_ticket_url(@event, @ticket), params: { ticket: { title: "Updated Title" } }
    assert_redirected_to admin_event_tickets_path(@event)
    assert_equal "Updated Title", @ticket.reload.title
  end
end
