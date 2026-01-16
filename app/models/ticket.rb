class Ticket < ApplicationRecord
  belongs_to :event
  has_many :order_items
  has_many :orders, through: :order_items

  def sold_out?
    order_items.sum(:quantity) >= quantity
  end
end
