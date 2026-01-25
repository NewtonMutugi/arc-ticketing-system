class Event < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged
  has_many :tickets, dependent: :destroy
  has_many :attendees, dependent: :destroy
  has_many :order_items, through: :tickets
  has_many :orders, through: :order_items


  validates :title, :description,  presence: true

  has_one_attached :event_image

  validates :event_image, content_type: [ "image/png", "image/jpeg" ], size: { less_than: 5.megabytes }

  def tickets_sold
    order_items.joins(:order).where(orders: { status: :paid }).sum(:quantity)
  end

  def transaction_count
    orders.where(status: :paid).distinct.count
  end

  def total_order_count
    orders.distinct.count
  end

  def revenue
    order_items.joins(:order)
               .where(orders: { status: :paid })
               .sum("order_items.unit_price * order_items.quantity")
  end

  def should_generate_new_friendly_id?
    title_changed?
  end
end
