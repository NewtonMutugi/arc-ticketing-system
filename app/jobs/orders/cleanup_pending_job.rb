class Orders::CleanupPendingJob < ApplicationJob
  queue_as :default

  def perform(*args)
    stale_count = Order.draft.where("created_at < ?", 5.days.ago).delete_all
    Rails.logger.info "Deleted #{stale_count} abandoned drafts."
  end
end
