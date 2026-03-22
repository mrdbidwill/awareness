# frozen_string_literal: true

class CreateMrCharacterMushroomColors < ActiveRecord::Migration[8.0]
  def change
    create_table :mr_character_mushroom_colors do |t|
      t.references :mr_character_mushroom, null: false, foreign_key: true, index: { name: 'index_mcm_colors_on_mcm_id' }
      t.references :color, null: false, foreign_key: true
      t.integer :display_order, null: false, default: 1, comment: '1=primary, 2=secondary, etc.'

      t.timestamps
    end

    # Ensure unique color per character-mushroom combination
    add_index :mr_character_mushroom_colors,
              [:mr_character_mushroom_id, :color_id],
              unique: true,
              name: 'index_mcm_colors_unique'

    # Index for querying by color (e.g., "find all mushrooms with red cap")
    add_index :mr_character_mushroom_colors,
              [:color_id, :mr_character_mushroom_id],
              name: 'index_mcm_colors_on_color'
  end
end
