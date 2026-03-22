# frozen_string_literal: true

class CreateLookupItems < ActiveRecord::Migration[8.0]
  def change
create_table :lookup_items do |t|
      t.references :mr_character, foreign_key: true
      t.string :name
      t.text :description
      t.text :comments
      t.references :source_data, foreign_key: true
      t.timestamps
    end
  end
end

