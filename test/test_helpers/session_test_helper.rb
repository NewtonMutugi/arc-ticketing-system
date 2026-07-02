module SessionTestHelper
  def sign_in_as(user, created_at = Time.current, updated_at = created_at)
    Current.session = user.sessions.create!(created_at: created_at, updated_at: updated_at)

    ActionDispatch::TestRequest.create.cookie_jar.tap do |cookie_jar|
      cookie_jar.signed[:session_id] = Current.session.id
      cookies["session_id"] = cookie_jar[:session_id]
    end
  end

  def sign_out
    Current.session&.destroy!
    cookies.delete("session_id")
  end
end

ActiveSupport.on_load(:action_dispatch_integration_test) do
  include SessionTestHelper
end
