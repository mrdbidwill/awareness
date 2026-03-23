class CreateAllGroupMushrooms < ActiveRecord::Migration[8.0]
  def change
  create_table :all_group_mushrooms do |t|
      t.references :all_group, null: false, foreign_key: true
      t.references :mushroom, null: false, foreign_key: true
      t.timestamps
    end
  end
end
