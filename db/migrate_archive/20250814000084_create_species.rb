class CreateSpecies < ActiveRecord::Migration[8.0]
  def change
    create_table :species do |t|
      t.string :mblist_id
      t.string :taxon_name, null: false # Taxon name should not be null
      t.references :genera, null: false, foreign_key: { to_table: :genera }
      t.timestamps
    end

    add_index :species, :taxon_name, unique: true # Ensure no duplicate taxon names
  end
end