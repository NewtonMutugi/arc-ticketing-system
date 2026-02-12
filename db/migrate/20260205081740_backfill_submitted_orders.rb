class BackfillSubmittedOrders < ActiveRecord::Migration[8.1]
  def up
    Order.where(status: 0)
          .where.not(payment_reference: [ nil, "" ])
          .update_all(status: 4)

    puts "Updated orders awaiting verification to 'submitted' status."
  end

  def down
    # Rollback logic (move submitted back to draft)
    Order.where(status: 4).update_all(status: 0)
  end
end
