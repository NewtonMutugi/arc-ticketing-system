class Session < ApplicationRecord
  MAX_AGE = 2.hours

  belongs_to :user

  scope :active, -> { where("updated_at > ?", MAX_AGE.ago) }

  def expired?
    updated_at <= MAX_AGE.ago
  end
end
