class AddOrderNoToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :order_no, :string
    add_index :orders, :order_no, unique: true
  end
end
