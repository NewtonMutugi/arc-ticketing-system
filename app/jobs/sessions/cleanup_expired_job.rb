class Sessions::CleanupExpiredJob < ApplicationJob
  queue_as :default

  def perform(*args)
    expired_count = Session.where("updated_at <= ?", Session::MAX_AGE.ago).delete_all

    Rails.logger.info "Deleted #{expired_count} expired sessions."
  end
end
