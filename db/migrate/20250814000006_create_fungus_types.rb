class CreateFungusTypes < ActiveRecord::Migration[8.0]
  def change
  create_table :fungus_types do |t|
      t.string :name
      t.text :description
      t.text :comments
      t.timestamps
    end
  end
end
