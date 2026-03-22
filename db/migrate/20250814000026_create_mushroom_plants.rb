class CreateMushroomPlants < ActiveRecord::Migration[8.0]
  def change
    create_table :mushroom_plants do |t|
      t.references :mushroom, null: false, foreign_key: true
      t.references :plant, null: false, foreign_key: true
      t.timestamps
    end
  end
end