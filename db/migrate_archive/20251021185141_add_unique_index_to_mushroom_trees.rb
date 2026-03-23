class AddUniqueIndexToMushroomTrees < ActiveRecord::Migration[8.0]
  def change
    # Remove any duplicate records before adding unique constraint (MySQL compatible)
    execute <<-SQL
      DELETE t1 FROM mushroom_trees t1
      INNER JOIN mushroom_trees t2
      WHERE t1.id > t2.id
        AND t1.mushroom_id = t2.mushroom_id
        AND t1.tree_id = t2.tree_id
    SQL

    # Add unique composite index (existing indexes remain for foreign key constraints)
    add_index :mushroom_trees, [:mushroom_id, :tree_id], unique: true, name: 'index_mushroom_trees_on_mushroom_id_and_tree_id'
  end
end
