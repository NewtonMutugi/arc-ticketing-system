class CreateCheckIns < ActiveRecord::Migration[8.1]
  def change
    create_table :check_ins do |t|
      t.references :attendee, null: false, foreign_key: true
      t.date :date

      t.timestamps
    end
    add_index :check_ins, [ :attendee_id, :date ], unique: true
  end
end
