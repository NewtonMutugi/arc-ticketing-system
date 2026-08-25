class AddPaymentFieldsToTicketUpgrades < ActiveRecord::Migration[8.1]
  def change
    add_column :ticket_upgrades, :status, :integer, default: 1
    add_column :ticket_upgrades, :checkout_request_id, :string
    add_column :ticket_upgrades, :payment_reference, :string
    add_column :ticket_upgrades, :payment_provider, :string
  end
end
