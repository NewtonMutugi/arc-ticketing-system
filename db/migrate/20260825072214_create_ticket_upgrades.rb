class CreateTicketUpgrades < ActiveRecord::Migration[8.1]
  def change
    create_table :ticket_upgrades do |t|
      t.references :attendee, null: false, foreign_key: true
      t.references :from_ticket, null: false, foreign_key: { to_table: :tickets }
      t.references :to_ticket, null: false, foreign_key: { to_table: :tickets }
      t.references :upgraded_by_user, null: false, foreign_key: { to_table: :users }
      t.decimal :amount_paid, precision: 10, scale: 2

      t.timestamps
    end
  end
end
