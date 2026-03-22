# frozen_string_literal: true

class AddCoreSequenceToMrCharacters < ActiveRecord::Migration[8.0]
  def change
    add_column :mr_characters, :core_sequence, :integer, if_not_exists: true
    add_index :mr_characters, :core_sequence, if_not_exists: true
  end
end
