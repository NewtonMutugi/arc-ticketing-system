class CreateTickets < ActiveRecord::Migration[8.1]
  def change
    create_table :tickets do |t|
      t.string :title
      t.float :price
      t.integer :quantity
      t.text :description
      t.date :start_sale_date
      t.date :end_sale_date
      t.integer :min_ticket
      t.integer :max_ticket
      t.integer :group_ticket_count
      t.boolean :status

      t.timestamps
    end
  end
end
