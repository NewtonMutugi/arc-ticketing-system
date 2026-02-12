class AddTransactionDetailsToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :checkout_request_id, :string
    add_column :orders, :merchant_request_id, :string
    add_column :orders, :paypal_order_id, :string
    add_column :orders, :transaction_receipt, :string
  end
end
