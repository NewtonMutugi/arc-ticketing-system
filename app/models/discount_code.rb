class DiscountCode < ApplicationRecord
  belongs_to :event
  has_many :discount_code_tickets, dependent: :destroy
  has_many :tickets, through: :discount_code_tickets

  enum :discount_type, { percentage: 0, fixed_amount: 1 }

  validates :code, presence: true, uniqueness: { scope: :event_id }
  validates :discount_amount, presence: true, numericality: { greater_than: 0 }
  validates :discount_type, presence: true

  before_validation :upcase_code

  def applies_to?(ticket)
    tickets.exists?(id: ticket.id)
  end

  def valid_for_use?
    return false unless active?
    return false if valid_until.present? && Time.current > valid_until
    return false if max_uses.present? && uses_count.to_i >= max_uses
    true
  end

  def calculate_discount(original_price, quantity = 1)
    return 0 unless valid_for_use?

    discount_per_ticket = if percentage?
      (original_price * (discount_amount / 100.0)).round(2)
    else
      discount_amount
    end

    discount_per_ticket = [discount_per_ticket, original_price].min
    discount_per_ticket * quantity
  end

  private

  def upcase_code
    self.code = code.upcase if code.present?
  end
end
