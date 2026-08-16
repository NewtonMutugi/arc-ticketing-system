class RemoveCheckedInAtFromAttendees < ActiveRecord::Migration[8.1]
  def change
    remove_column :attendees, :checked_in_at, :datetime
  end
end
