class Event < ApplicationRecord
  has_many :tickets, dependent: :destroy
  has_many :attendees, dependent: :destroy
  has_many :order_items, through: :tickets
  has_many :orders, through: :order_items


  validates :title, :description,  presence: true

  has_one_attached :event_image

  validates :event_image, content_type: [ "image/png", "image/jpeg" ], size: { less_than: 5.megabytes }
end
