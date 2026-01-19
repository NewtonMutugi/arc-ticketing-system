class Event < ApplicationRecord
  has_many :tickets, dependent: :destroy

  validates :title, :description,  presence: true

  has_one_attached :event_image

  validates :event_image, content_type: [ "image/png", "image/jpeg" ], size: { less_than: 5.megabytes }
end
