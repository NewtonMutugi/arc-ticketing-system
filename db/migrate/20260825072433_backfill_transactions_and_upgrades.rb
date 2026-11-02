class BackfillTransactionsAndUpgrades < ActiveRecord::Migration[8.1]
  def up
    # 1. Backfill Orders to Transactions
    Order.where(status: 1).find_each do |order|
      # status: 1 is paid. Only backfill paid orders as successful payments.
      event_id = order.order_items.first&.ticket&.event_id
      next unless event_id

      Transaction.create!(
        event_id: event_id,
        amount: order.total_cost || 0,
        referenceable: order,
        transaction_type: "order_payment"
      )
    end

    # 2. Detect and Backfill Historical Upgrades
    Order.includes(:order_items, :attendees).find_each do |order|
      # Gather order items by ticket_id and their quantities
      available_items = {}
      order.order_items.each do |item|
        available_items[item.ticket_id] ||= 0
        available_items[item.ticket_id] += item.quantity
      end

      upgraded_attendees = []

      # Pair attendees to order items
      order.attendees.each do |attendee|
        if available_items[attendee.ticket_id] && available_items[attendee.ticket_id] > 0
          available_items[attendee.ticket_id] -= 1
        else
          upgraded_attendees << attendee
        end
      end

      # For the attendees that were upgraded, pair them with the remaining order item quantities to find out what ticket they were upgraded FROM
      unpaired_tickets = []
      available_items.each do |ticket_id, remaining_qty|
        remaining_qty.times { unpaired_tickets << ticket_id }
      end

      # Get an admin user for the upgraded_by_user_id fallback
      admin_user_id = order.approved_by_user_id || User.where(role: :admin).first&.id || User.first&.id

      upgraded_attendees.each_with_index do |attendee, index|
        from_ticket_id = unpaired_tickets[index] || order.order_items.first&.ticket_id

        next if from_ticket_id.nil? || from_ticket_id == attendee.ticket_id

        # Calculate price difference if possible
        to_ticket = Ticket.find_by(id: attendee.ticket_id)
        from_ticket = Ticket.find_by(id: from_ticket_id)

        amount_paid = 0
        if to_ticket && from_ticket
          amount_paid = [ to_ticket.price - from_ticket.price, 0 ].max
        end

        upgrade = TicketUpgrade.create!(
          attendee_id: attendee.id,
          from_ticket_id: from_ticket_id,
          to_ticket_id: attendee.ticket_id,
          upgraded_by_user_id: admin_user_id,
          amount_paid: amount_paid
        )

        # Only create transaction if there was a price difference
        if amount_paid > 0
          Transaction.create!(
            event_id: attendee.event_id,
            amount: amount_paid,
            referenceable: upgrade,
            transaction_type: "ticket_upgrade"
          )
        end
      end
    end
  end

  def down
    Transaction.destroy_all
    TicketUpgrade.destroy_all
  end
end
