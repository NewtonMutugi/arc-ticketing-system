class AddEventToTickets < ActiveRecord::Migration[8.1]
  def change
    add_reference :tickets, :event, null: false, foreign_key: true
  end
end
