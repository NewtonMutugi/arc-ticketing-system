class AddPaymentDetailsToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :payment_provider, :string
    add_column :orders, :payment_reference, :string
  end
end
