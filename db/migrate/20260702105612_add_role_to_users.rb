class AddRoleToUsers < ActiveRecord::Migration[8.1]
  def up
    add_column :users, :role, :integer, default: 0, null: false
    
    # Migrate existing admins to role: 2 (admin)
    execute("UPDATE users SET role = 2 WHERE admin = true")

    remove_column :users, :admin
  end

  def down
    add_column :users, :admin, :boolean, default: false, null: false
    
    execute("UPDATE users SET admin = true WHERE role = 2")
    
    remove_column :users, :role
  end
end
