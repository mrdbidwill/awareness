class CreateMushroomProjects < ActiveRecord::Migration[8.0]
  def change
    create_table :mushroom_projects do |t|
      t.references :mushroom, null: false, foreign_key: true
      t.references :project, null: false, foreign_key: true
      t.timestamps
    end
  end
end