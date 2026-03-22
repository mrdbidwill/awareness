class AddLocationToImageMushrooms < ActiveRecord::Migration[8.0]
  def change
    add_column :image_mushrooms, :latitude, :decimal, precision: 10, scale: 7
    add_column :image_mushrooms, :longitude, :decimal, precision: 10, scale: 7
  end
end
