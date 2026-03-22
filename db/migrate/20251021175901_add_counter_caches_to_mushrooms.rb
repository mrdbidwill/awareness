class AddCounterCachesToMushrooms < ActiveRecord::Migration[8.0]
  def change
    add_column :mushrooms, :trees_count, :integer, default: 0, null: false
    add_column :mushrooms, :plants_count, :integer, default: 0, null: false
    add_column :mushrooms, :mr_character_mushrooms_count, :integer, default: 0, null: false

    # Reset counters for existing records
    reversible do |dir|
      dir.up do
        # Use raw SQL for better performance on large datasets
        execute <<-SQL.squish
          UPDATE mushrooms
          SET trees_count = (
            SELECT COUNT(*) FROM mushroom_trees WHERE mushroom_trees.mushroom_id = mushrooms.id
          )
        SQL

        execute <<-SQL.squish
          UPDATE mushrooms
          SET plants_count = (
            SELECT COUNT(*) FROM mushroom_plants WHERE mushroom_plants.mushroom_id = mushrooms.id
          )
        SQL

        execute <<-SQL.squish
          UPDATE mushrooms
          SET mr_character_mushrooms_count = (
            SELECT COUNT(*) FROM mr_character_mushrooms WHERE mr_character_mushrooms.mushroom_id = mushrooms.id
          )
        SQL
      end
    end
  end
end
