class ChangeStatusToIntegerInOrders < ActiveRecord::Migration[8.1]
  def change
    change_column :orders, :status, :integer, default: 0, using: 'status::integer'
  end
end
