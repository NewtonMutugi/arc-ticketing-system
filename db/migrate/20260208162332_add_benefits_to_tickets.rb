class AddBenefitsToTickets < ActiveRecord::Migration[8.1]
  def change
    add_column :tickets, :benefits, :text
  end
end
