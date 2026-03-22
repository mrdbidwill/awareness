class CreateAllGroups < ActiveRecord::Migration[8.0]
  def change
  create_table :all_groups do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.text :description
      t.text :comments
      t.timestamps
    end
  end
end
