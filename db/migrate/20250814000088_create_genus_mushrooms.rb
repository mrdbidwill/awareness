class CreateGenusMushrooms < ActiveRecord::Migration[8.0]
  def change
    create_table :genus_mushrooms do |t|
      t.references :genus, null: false, foreign_key: { to_table: :genera }
      t.references :mushroom, null: false, foreign_key: true
      t.timestamps
    end
  end
end

