class ChangeFloatToDecimal < ActiveRecord::Migration[8.1]
  def change
    change_column :tickets, :price, :decimal, precision: 10, scale: 2
    change_column :order_items, :unit_price, :decimal, precision: 10, scale: 2
    change_column :orders, :total_cost, :decimal, precision: 10, scale: 2
  end
end
