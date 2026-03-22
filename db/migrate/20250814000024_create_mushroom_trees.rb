class CreateMushroomTrees < ActiveRecord::Migration[8.0]
  def change
    create_table :mushroom_trees do |t|
      t.references :mushroom, null: false, foreign_key: true
      t.references :tree, null: false, foreign_key: true
      t.timestamps
    end
  end
end
