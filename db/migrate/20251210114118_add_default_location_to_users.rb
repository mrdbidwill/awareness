class AddDefaultLocationToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :default_country_id, :bigint, null: true
    add_column :users, :default_state_id, :bigint, null: true
    add_column :users, :default_city, :string, limit: 255
    add_column :users, :default_county, :string, limit: 255

    add_foreign_key :users, :countries, column: :default_country_id, on_delete: :nullify
    add_foreign_key :users, :states, column: :default_state_id, on_delete: :nullify
    add_index :users, :default_country_id
    add_index :users, :default_state_id
  end
end
