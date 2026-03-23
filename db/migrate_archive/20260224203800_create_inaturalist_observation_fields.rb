class CreateInaturalistObservationFields < ActiveRecord::Migration[8.0]
  def change
    create_table :inaturalist_observation_fields do |t|
      t.integer :inaturalist_id, null: false
      t.string :name, null: false
      t.string :datatype
      t.integer :user_id
      t.text :description
      t.text :allowed_values
      t.integer :values_count
      t.integer :users_count
      t.string :uuid
      t.timestamps null: false
    end

    # Add indexes for search performance
    add_index :inaturalist_observation_fields, :inaturalist_id, unique: true
    add_index :inaturalist_observation_fields, :name
    add_index :inaturalist_observation_fields, :uuid, unique: true
    add_index :inaturalist_observation_fields, :created_at
  end
end
