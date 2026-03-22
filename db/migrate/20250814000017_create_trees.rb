class CreateTrees < ActiveRecord::Migration[8.0]
  def change
    create_table :trees do |t|
      t.string :name
      t.text :description
      t.text :comments
      t.timestamps
    end
  end
end
