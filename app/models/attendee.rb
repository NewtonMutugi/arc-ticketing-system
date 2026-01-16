class Attendee < ApplicationRecord
  belongs_to :order
  belongs_to :event
  belongs_to :ticket
end
