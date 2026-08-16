class Attendee < ApplicationRecord
  belongs_to :order
  belongs_to :event
  belongs_to :ticket
  has_many :check_ins, dependent: :destroy

  def checked_in?(date)
    check_ins.exists?(date: date)
  end
end
