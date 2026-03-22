class AddIsPrimaryToJoinTables < ActiveRecord::Migration[8.0]
  def change
    add_column :genus_mushrooms, :is_primary, :boolean, default: false, null: false unless column_exists?(:genus_mushrooms, :is_primary)
    add_column :mushroom_species, :is_primary, :boolean, default: false, null: false unless column_exists?(:mushroom_species, :is_primary)
  end
end
