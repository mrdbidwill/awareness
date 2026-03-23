class AddUniqueIndexToMushroomPlants < ActiveRecord::Migration[8.0]
  def change
    # Remove any duplicate records before adding unique constraint (MySQL compatible)
    execute <<-SQL
      DELETE t1 FROM mushroom_plants t1
      INNER JOIN mushroom_plants t2
      WHERE t1.id > t2.id
        AND t1.mushroom_id = t2.mushroom_id
        AND t1.plant_id = t2.plant_id
    SQL

    # Add unique composite index (existing indexes remain for foreign key constraints)
    add_index :mushroom_plants, [:mushroom_id, :plant_id], unique: true, name: 'index_mushroom_plants_on_mushroom_id_and_plant_id'
  end
end
