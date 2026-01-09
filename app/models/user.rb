class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :first_name, :last_name, presence: true

  has_one_attached :avatar

  validates :avatar, content_type: [ "imgae/jpeg", "image/png" ], size: { less_than: 5.megabytes }

  def full_name
    "#{first_name} #{last_name}"
  end
end
