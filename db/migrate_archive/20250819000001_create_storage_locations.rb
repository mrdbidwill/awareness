class CreateStorageLocations < ActiveRecord::Migration[8.0]
  def change
    create_table :storage_locations do |t|
      t.string :name
      t.text :description
      t.text :comments
      t.timestamps
    end
  end
end