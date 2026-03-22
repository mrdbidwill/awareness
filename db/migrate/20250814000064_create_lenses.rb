class CreateLenses < ActiveRecord::Migration[8.0]
  def change
  create_table :lenses do |t|
      t.string :make
      t.string :model
      t.text :description
      t.text :comments
      t.timestamps
    end
  end
end
