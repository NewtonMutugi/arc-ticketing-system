class Order < ApplicationRecord
  has_many :order_items, dependent: :destroy
  has_many :tickets, through: :order_items

  before_create :generate_order_number


  private
  def generate_order_number
    loop do
      self.order_number = "ARC-#{SecureRandom.hex(8).upcase}"

      break unless Order.exists?(order_no: order_no)
    end
  end
end
