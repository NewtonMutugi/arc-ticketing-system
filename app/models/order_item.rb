class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :ticket

  def total_price
    quantity * (unit_price || ticket.price || 0)
  end
end
