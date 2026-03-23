# db/migrate/create_parts.rb
class CreateParts < ActiveRecord::Migration[8.0]
  def change
    create_table :parts do |t|
      t.string :name
      t.text :description
      t.text :comments
      t.timestamps
    end
  end
end
