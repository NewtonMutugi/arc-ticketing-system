class Ticket < ApplicationRecord
  include Auditable
  include Hashid::Rails

  belongs_to :event
  belongs_to :user, foreign_key: "created_by_user_id", optional: true
  has_many :order_items
  has_many :orders, through: :order_items
  has_many :upgrades_in, class_name: "TicketUpgrade", foreign_key: "to_ticket_id"
  has_many :upgrades_out, class_name: "TicketUpgrade", foreign_key: "from_ticket_id"

  has_many :discount_code_tickets, dependent: :destroy
  has_many :discount_codes, through: :discount_code_tickets

  has_one_attached :ticket_image

  validates :ticket_image, content_type: [ "image/png", "image/jpeg" ], size: { less_than: 5.megabytes }

  track_audit_on :title, :description, :price, :quantity, :status, :benefits, :min_ticket, :max_ticket

  def tickets_sold
    base_sold = order_items.joins(:order)
               .where.not(orders: { status: [ :failed, :refunded ] })
               .sum(:quantity)
    base_sold + upgrades_in.count - upgrades_out.count
  end

  def tickets_left
    [ quantity - tickets_sold, 0 ].max
  end

  def sold_out?
    tickets_left.zero?
  end

  def revenue
    base_revenue = order_items.joins(:order)
               .where(orders: { status: [ :paid, :submitted ] })
               .sum("order_items.quantity * order_items.unit_price")
    base_revenue + upgrades_in.sum(:amount_paid)
  end

  def created_by
    user
  end
end
