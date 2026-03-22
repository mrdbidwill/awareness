class CreateClusterMushrooms < ActiveRecord::Migration[8.0]
  def change
  create_table :cluster_mushrooms do |t|
      t.references :cluster, null: false, foreign_key: true
      t.references :mushroom, null: false, foreign_key: true
      t.timestamps
    end
  end
end
