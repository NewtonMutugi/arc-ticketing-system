class AddTokenAndCheckInToAttendees < ActiveRecord::Migration[8.1]
  def change
    add_column :attendees, :token, :string
    add_index :attendees, :token, unique: true

    remove_column :attendees, :checked_in, :boolean
    add_column :attendees, :checked_in_at, :datetime
  end
end
