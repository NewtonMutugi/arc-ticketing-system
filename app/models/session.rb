class Session < ApplicationRecord
  belongs_to :user

  scope :active, -> { where("updated_at > ?", max_age.ago) }

  def self.max_age
    Setting.session_timeout.to_i.minutes
  end

  def expired?
    updated_at <= self.class.max_age.ago
  end
end
