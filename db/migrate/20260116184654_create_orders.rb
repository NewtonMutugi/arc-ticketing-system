class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.string :buyer_name
      t.string :buyer_email
      t.string :buyer_phone_no
      t.integer :total_items
      t.float :total_cost
      t.boolean :status

      t.timestamps
    end
  end
end
