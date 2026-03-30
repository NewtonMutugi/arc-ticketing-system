class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :created_events, class_name: "Event", foreign_key: "created_by_user_id", dependent: :nullify
  has_many :created_tickets, class_name: "Ticket", foreign_key: "created_by_user_id", dependent: :nullify
  has_many :approved_orders, class_name: "Order", foreign_key: "approved_by_user_id", dependent: :nullify
  has_many :audit_logs, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :first_name, :last_name, presence: true

  has_one_attached :avatar

  validates :avatar, content_type: [ "image/png", "image/jpeg" ], size: { less_than: 5.megabytes }

  def full_name
    "#{first_name} #{last_name}"
  end

  def admin?
    admin
  end
end
