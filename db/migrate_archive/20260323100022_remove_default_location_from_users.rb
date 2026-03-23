class RemoveDefaultLocationFromUsers < ActiveRecord::Migration[8.0]
  def up
    if column_exists?(:users, :default_country_id)
      remove_foreign_key :users, column: :default_country_id if foreign_key_exists?(:users, column: :default_country_id)
      remove_index :users, :default_country_id if index_exists?(:users, :default_country_id)
      remove_column :users, :default_country_id
    end

    if column_exists?(:users, :default_state_id)
      remove_foreign_key :users, column: :default_state_id if foreign_key_exists?(:users, column: :default_state_id)
      remove_index :users, :default_state_id if index_exists?(:users, :default_state_id)
      remove_column :users, :default_state_id
    end

    remove_column :users, :default_city if column_exists?(:users, :default_city)
    remove_column :users, :default_county if column_exists?(:users, :default_county)
  end

  def down
    add_column :users, :default_country_id, :bigint unless column_exists?(:users, :default_country_id)
    add_column :users, :default_state_id, :bigint unless column_exists?(:users, :default_state_id)
    add_column :users, :default_city, :string unless column_exists?(:users, :default_city)
    add_column :users, :default_county, :string unless column_exists?(:users, :default_county)

    add_index :users, :default_country_id unless index_exists?(:users, :default_country_id)
    add_index :users, :default_state_id unless index_exists?(:users, :default_state_id)

    add_foreign_key :users, :countries, column: :default_country_id, on_delete: :nullify unless foreign_key_exists?(:users, :countries, column: :default_country_id)
    add_foreign_key :users, :states, column: :default_state_id, on_delete: :nullify unless foreign_key_exists?(:users, :states, column: :default_state_id)
  end
end
