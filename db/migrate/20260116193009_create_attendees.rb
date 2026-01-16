class CreateAttendees < ActiveRecord::Migration[8.1]
  def change
    create_table :attendees do |t|
      t.string :first_name
      t.string :last_name
      t.string :preferred_name
      t.string :email
      t.boolean :checked_in
      t.references :order, null: false, foreign_key: true
      t.references :event, null: false, foreign_key: true
      t.references :ticket, null: false, foreign_key: true

      t.timestamps
    end
  end
end
