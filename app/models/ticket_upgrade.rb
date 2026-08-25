class TicketUpgrade < ApplicationRecord
  belongs_to :attendee
  belongs_to :from_ticket, class_name: "Ticket"
  belongs_to :to_ticket, class_name: "Ticket"
  belongs_to :upgraded_by_user, class_name: "User"
  has_one :payment_transaction, class_name: "Transaction", as: :referenceable, dependent: :destroy

  enum :status, { pending: 0, paid: 1, failed: 2 }

  def apply_upgrade!
    return if attendee.ticket_id == to_ticket_id

    attendee.update!(ticket_id: to_ticket_id)
    generate_transaction
    OrderMailer.ticket_change_email(attendee, from_ticket).deliver_later
  end

  private

  def generate_transaction
    return unless amount_paid && amount_paid > 0

    Transaction.create!(
      event_id: attendee.event_id,
      amount: amount_paid,
      referenceable: self,
      transaction_type: "ticket_upgrade"
    )
  end
end
