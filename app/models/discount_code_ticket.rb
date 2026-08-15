class DiscountCodeTicket < ApplicationRecord
  belongs_to :discount_code
  belongs_to :ticket
end
