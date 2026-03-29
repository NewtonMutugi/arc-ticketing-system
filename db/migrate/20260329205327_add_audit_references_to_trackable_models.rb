class AddAuditReferencesToTrackableModels < ActiveRecord::Migration[8.1]
  def change
    # Add creator and last updater references
    add_column :events, :created_by_user_id, :bigint
    add_column :events, :updated_by_user_id, :bigint
    add_foreign_key :events, :users, column: :created_by_user_id

    add_column :tickets, :created_by_user_id, :bigint
    add_column :tickets, :updated_by_user_id, :bigint
    add_foreign_key :tickets, :users, column: :created_by_user_id

    add_column :orders, :approved_by_user_id, :bigint
    add_column :orders, :approved_at, :datetime
    add_column :orders, :approval_notes, :text
    add_foreign_key :orders, :users, column: :approved_by_user_id

    add_index :events, :created_by_user_id
    add_index :events, :updated_by_user_id
    add_index :tickets, :created_by_user_id
    add_index :tickets, :updated_by_user_id
    add_index :orders, :approved_by_user_id
  end
end
