class AuditLog < ApplicationRecord
  belongs_to :user
  belongs_to :auditable, polymorphic: true

  enum :action, {
    created: 0,
    updated: 1,
    deleted: 2,
    approved: 3,
    rejected: 4,
    payment_approved: 5,
    payment_rejected: 6
  }

  scope :recent, -> { order(created_at: :desc) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :by_action, ->(action) { where(action: action) }
  scope :by_model, ->(model_type) { where(auditable_type: model_type) }

  def self.log_action(user, action, auditable, changes: nil, status: nil, reason: nil, ip_address: nil, user_agent: nil)
    create(
      user: user,
      action: action,
      auditable: auditable,
      changes: changes&.to_json,
      status: status,
      reason: reason,
      ip_address: ip_address,
      user_agent: user_agent
    )
  end

  def changes_hash
    return {} if changes.blank?
    JSON.parse(changes)
  end
end
