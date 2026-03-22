# frozen_string_literal: true

class CreateCoreCharacterSequences < ActiveRecord::Migration[8.0]
  def change
    create_table :core_character_sequences, if_not_exists: true do |t|
      t.references :fungus_type, null: false, foreign_key: true
      t.references :mr_character, null: false, foreign_key: true
      t.integer :sequence, null: false

      t.timestamps
    end

    add_index :core_character_sequences, [:fungus_type_id, :mr_character_id], unique: true, name: "index_core_sequences_on_fungus_and_character", if_not_exists: true
    add_index :core_character_sequences, [:fungus_type_id, :sequence], name: "index_core_sequences_on_fungus_and_sequence", if_not_exists: true
  end
end
