class Sessions::CleanupExpiredJob < ApplicationJob
  queue_as :default

  def perform(*args)
    expired_count = Session.where("updated_at <= ?", Session.max_age.ago).delete_all

    Rails.logger.info "Deleted #{expired_count} expired sessions."
  end
end
