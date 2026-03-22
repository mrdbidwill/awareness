class AddTemporaryAdminFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :temporary_admin, :boolean, default: false, null: false
    add_column :users, :admin_expires_at, :datetime
    add_index :users, :admin_expires_at
  end
end
