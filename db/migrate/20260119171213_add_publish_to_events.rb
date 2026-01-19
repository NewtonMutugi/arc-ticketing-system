class AddPublishToEvents < ActiveRecord::Migration[8.1]
  def change
    add_column :events, :publish, :boolean
  end
end
