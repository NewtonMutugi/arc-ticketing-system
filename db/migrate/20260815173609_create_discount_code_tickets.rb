class CreateDiscountCodeTickets < ActiveRecord::Migration[8.1]
  def change
    create_table :discount_code_tickets do |t|
      t.references :discount_code, null: false, foreign_key: true
      t.references :ticket, null: false, foreign_key: true

      t.timestamps
    end
  end
end
