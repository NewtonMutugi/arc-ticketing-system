class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events do |t|
      t.string :title
      t.string :description
      t.date :start_date
      t.date :end_date
      t.string :location

      t.timestamps
    end
  end
end
