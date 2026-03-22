class CreateImageMushrooms < ActiveRecord::Migration[8.0]
  def change
  create_table :image_mushrooms do |t|
      t.references :mushroom, null: false, foreign_key: true
      t.references :part, foreign_key: true
      t.references :camera_make, foreign_key: true
      t.references :camera_model, foreign_key: true
      t.string :image_name
      t.integer :image_width
      t.integer :image_height
      t.string :lens
      t.string :exposure
      t.string :aperture
      t.string :iso
      t.timestamps
  end
  end
end


