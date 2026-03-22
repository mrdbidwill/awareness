# frozen_string_literal: true

class RemoveLegacyCoreSequenceFromMrCharacters < ActiveRecord::Migration[8.0]
  def change
    if index_exists?(:mr_characters, :core_sequence)
      remove_index :mr_characters, :core_sequence
    end

    if column_exists?(:mr_characters, :core_sequence)
      remove_column :mr_characters, :core_sequence
    end
  end
end
