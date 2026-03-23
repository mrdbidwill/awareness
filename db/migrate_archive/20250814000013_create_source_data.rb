# frozen_string_literal: true

class CreateSourceData < ActiveRecord::Migration[8.0]
  def change
    create_table :source_data do |t|
      t.string :title
      t.string :author
      t.string :ref
      t.string :item_code
      t.references :source_data_type, null: false, foreign_key: true
      t.text :comments
      t.timestamps
    end
  end
end
