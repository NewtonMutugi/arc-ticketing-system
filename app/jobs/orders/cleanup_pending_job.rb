class Orders::CleanupPendingJob < ApplicationJob
  queue_as :default

  def perform(*args)
    stale_orders = Order.draft.where("created_at < ?", 5.days.ago)

    # Delete the child records first to satisfy the foreign key constraint
    OrderItem.where(order: stale_orders).delete_all
    stale_count = stale_orders.delete_all

    Rails.logger.info "Deleted #{stale_count} abandoned drafts."
  end
end
