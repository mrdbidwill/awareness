# frozen_string_literal: true

class MigrateExistingColorData < ActiveRecord::Migration[8.0]
  def up
    # Find all mr_character_mushrooms where the character has display_option_id = 6 (color)
    # and migrate their character_value (single color ID) to the new join table

    execute <<-SQL
      INSERT INTO mr_character_mushroom_colors (mr_character_mushroom_id, color_id, display_order, created_at, updated_at)
      SELECT
        mcm.id,
        CAST(mcm.character_value AS UNSIGNED) AS color_id,
        1 AS display_order,
        mcm.created_at,
        mcm.updated_at
      FROM mr_character_mushrooms mcm
      INNER JOIN mr_characters mc ON mcm.mr_character_id = mc.id
      WHERE mc.display_option_id = 6
        AND mcm.character_value IS NOT NULL
        AND mcm.character_value REGEXP '^[0-9]+$'
        AND CAST(mcm.character_value AS UNSIGNED) BETWEEN 1 AND 50
    SQL

    puts "Migrated #{MrCharacterMushroomColor.count} color records to join table"
  end

  def down
    # Reverse migration: copy primary color (display_order = 1) back to character_value
    execute <<-SQL
      UPDATE mr_character_mushrooms mcm
      INNER JOIN mr_characters mc ON mcm.mr_character_id = mc.id
      INNER JOIN mr_character_mushroom_colors mcmc ON mcm.id = mcmc.mr_character_mushroom_id
      SET mcm.character_value = mcmc.color_id
      WHERE mc.display_option_id = 6
        AND mcmc.display_order = 1
    SQL

    # Delete all records from join table
    execute "DELETE FROM mr_character_mushroom_colors"

    puts "Restored color data to character_value column"
  end
end
