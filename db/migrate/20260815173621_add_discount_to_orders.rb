class AddDiscountToOrders < ActiveRecord::Migration[8.1]
  def change
    add_reference :orders, :discount_code, null: true, foreign_key: true
    add_column :orders, :discount_amount, :decimal
  end
end
