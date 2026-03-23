class CreateMushroomSpecies < ActiveRecord::Migration[8.0]
  def change
    create_table :mushroom_species do |t|
      t.references :species, null: false, foreign_key: true
      t.references :mushroom, null: false, foreign_key: true
      t.timestamps
    end

    add_index :mushroom_species, [:mushroom_id, :species_id], unique: true # Composite index
  end
end

