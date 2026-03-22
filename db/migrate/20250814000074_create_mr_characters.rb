# Creates the mr_characters table
# frozen_string_literal: true

class CreateMrCharacters < ActiveRecord::Migration[8.0]
  def change
  create_table :mr_characters do |t|
      t.string :name
      t.text :description
      t.text :comments
      t.references :user, foreign_key: true
      t.references :tree, foreign_key: true
      t.references :part, null: false, foreign_key: true
      t.references :observation_method, null: false, foreign_key: true
      t.references :display_option, null: false, foreign_key: true
      t.references :source_data, null: false, foreign_key: true
      t.timestamps
    end
  end
end
