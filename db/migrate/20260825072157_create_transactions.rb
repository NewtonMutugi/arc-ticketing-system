class CreateTransactions < ActiveRecord::Migration[8.1]
  def change
    create_table :transactions do |t|
      t.references :event, null: false, foreign_key: true
      t.decimal :amount, precision: 10, scale: 2
      t.references :referenceable, polymorphic: true, null: false
      t.string :transaction_type

      t.timestamps
    end
  end
end
