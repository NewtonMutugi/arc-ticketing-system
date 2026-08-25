class Order < ApplicationRecord
  include Auditable

  has_many :order_items, dependent: :destroy
  has_many :tickets, through: :order_items
  has_many :attendees, dependent: :destroy
  has_one :payment_transaction, class_name: "Transaction", as: :referenceable, dependent: :destroy
  belongs_to :user, foreign_key: "approved_by_user_id", optional: true
  belongs_to :discount_code, optional: true

  before_create :generate_order_number

  after_update :generate_attendees, if: -> { saved_change_to_status? && paid? }
  after_update :generate_transaction, if: -> { saved_change_to_status? && paid? }
  after_update :log_payment_approval, if: :status_changed?
  after_update :increment_discount_usage, if: -> { saved_change_to_status? && paid? }

  enum :status, {
    draft: 0,   # Safe to auto-delete after 7 days
    paid: 1,      # Admin approved
    failed: 2,
    refunded: 3,
    submitted: 4 # User entered payment ref, waiting for Admin
  }

  track_audit_on :status, :payment_reference, :payment_provider, :transaction_receipt

  def to_param
    order_no
  end

  def approved_by
    user
  end

  def send_confirmation_emails!
    # Send to buyer
    OrderMailer.confirmation_email(self).deliver_later

    # Send to each attendee
    attendees.each do |attendee|
      next if attendee.email.blank?
      OrderMailer.attendee_ticket_email(attendee).deliver_later
    end
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
          token: SecureRandom.hex(6).upcase
        )
      end
    end
  end

  def generate_transaction
    return unless order_items.any?

    event_id = order_items.first.ticket.event_id
    Transaction.create!(
      event_id: event_id,
      amount: total_cost || 0,
      referenceable: self,
      transaction_type: "order_payment"
    )
  end

  def log_payment_approval
    return unless saved_change_to_status?

    user = Current.user || User.first
    return unless user

    case status.to_sym
    when :paid
      action_type = :payment_approved
      status_value = "approved"
    when :failed
      action_type = :payment_rejected
      status_value = "rejected"
    else
      return
    end

    AuditLog.log_action(
      user,
      action_type,
      self,
      status: status_value,
      reason: approval_notes,
      ip_address: Current.ip_address,
      user_agent: Current.user_agent
    )
  end

  def status_changed?
    saved_change_to_status?
  end

  def increment_discount_usage
    discount_code&.increment!(:uses_count)
  end
end
