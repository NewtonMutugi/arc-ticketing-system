class CheckIn < ApplicationRecord
  belongs_to :attendee
  has_one :event, through: :attendee

  validates :date, presence: true
  validates :date, uniqueness: { scope: :attendee_id, message: "already checked in for this date" }
  validate :date_within_event_dates

  private

  def date_within_event_dates
    return unless date && attendee&.event

    unless date.between?(attendee.event.start_date, attendee.event.end_date)
      errors.add(:date, "must be within the event dates (#{attendee.event.start_date} to #{attendee.event.end_date})")
    end
  end
end
