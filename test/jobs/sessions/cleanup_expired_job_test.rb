require "test_helper"

class Sessions::CleanupExpiredJobTest < ActiveJob::TestCase
  setup do
    @user = User.take
  end

  test "deletes expired sessions and preserves active ones" do
    # Create an active session
    active_session = @user.sessions.create!(created_at: 1.hour.ago, updated_at: 1.hour.ago)

    # Create an expired session
    expired_session = @user.sessions.create!(created_at: 3.hours.ago, updated_at: 3.hours.ago)

    assert_difference -> { Session.count }, -1 do
      Sessions::CleanupExpiredJob.perform_now
    end

    assert Session.exists?(active_session.id)
    assert_not Session.exists?(expired_session.id)
  end
end
