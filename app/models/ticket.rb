class Ticket < ApplicationRecord
  belongs_to :event
  has_many :order_items
  has_many :orders, through: :order_items

  has_one_attached :ticket_image

  validates :ticket_image, content_type: [ "image/png", "image/jpeg" ], size: { less_than: 5.megabytes }

  def tickets_sold
    order_items.joins(:order)
               .where.not(orders: { status: [ :failed, :refunded ] })
               .sum(:quantity)
  end

  def tickets_left
    [ quantity - tickets_sold, 0 ].max
  end

  def sold_out?
    tickets_left.zero?
  end

  def revenue
    order_items.joins(:order)
               .where(orders: { status: [ :paid, :submitted ] })
               .sum("order_items.quantity * order_items.unit_price")
  end
end
