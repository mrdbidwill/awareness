class AddIndexesAndConstraintsToGeneraAndSpecies < ActiveRecord::Migration[8.0]
  def change
    add_index :genera, :name, unique: true unless index_exists?(:genera, :name)
    add_index :species, [:genera_id, :name], unique: true unless index_exists?(:species, [:genera_id, :name])
    add_index :mushroom_species, [:mushroom_id, :species_id], unique: true unless index_exists?(:mushroom_species, [:mushroom_id, :species_id])
    add_index :genus_mushrooms, [:mushroom_id, :genus_id], unique: true unless index_exists?(:genus_mushrooms, [:mushroom_id, :genus_id])
    # Optional: Add boolean is_primary if you want to support “primary” flags
  end
end
