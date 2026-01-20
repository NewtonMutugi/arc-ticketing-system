class Ticket < ApplicationRecord
  belongs_to :event
  has_many :order_items
  has_many :orders, through: :order_items

  has_one_attached :ticket_image

  validates :ticket_image, content_type: [ "image/png", "image/jpeg" ], size: { less_than: 5.megabytes }

  def sold_out?
    order_items.sum(:quantity) >= quantity
  end
end
