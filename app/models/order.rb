class Order < ApplicationRecord
  has_many :order_items, dependent: :destroy
  has_many :tickets, through: :order_items
  has_many :attendees, dependent: :destroy

  before_create :generate_order_number

  after_update :generate_attendees, if: -> { saved_change_to_status? && paid? }

  enum :status, {
    pending: 0,
    paid: 1,
    failed: 2,
    refunded: 3
  }

  def to_param
    order_no
  end

  private
  def generate_order_number
    loop do
      self.order_no = "ARC-#{SecureRandom.hex(8).upcase}"

      break unless Order.exists?(order_no: order_no)
    end
  end

  def generate_attendees
    return if attendees.any?

    order_items.each do |item|
      item.quantity.times do
        attendees.create!(
          event: item.ticket.event,
          ticket: item.ticket,
          email: buyer_email,
          first_name: buyer_name.split.first,
          last_name: buyer_name.split.last,
          private_reference: SecureRandom.hex(6).upcase
        )
      end
    end
  end
end
