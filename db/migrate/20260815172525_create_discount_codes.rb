class CreateDiscountCodes < ActiveRecord::Migration[8.1]
  def change
    create_table :discount_codes do |t|
      t.string :code
      t.references :event, null: false, foreign_key: true
      t.integer :discount_type
      t.decimal :discount_amount
      t.integer :max_uses
      t.integer :uses_count
      t.datetime :valid_until
      t.boolean :active

      t.timestamps
    end
  end
end
