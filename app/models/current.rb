class Current < ActiveSupport::CurrentAttributes
  attribute :session
  attribute :ip_address
  attribute :user_agent

  delegate :user, to: :session, allow_nil: true
end
