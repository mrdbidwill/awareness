class UpdateSpeciesUniqueIndex < ActiveRecord::Migration[8.0]
  def change
    # Remove unique index on name if it exists
    remove_index :species, :name if index_exists?(:species, :name, unique: true)
    # Add unique composite index on [genera_id, name]
    add_index :species, [:genera_id, :name], unique: true unless index_exists?(:species, [:genera_id, :name], unique: true)
  end
end
