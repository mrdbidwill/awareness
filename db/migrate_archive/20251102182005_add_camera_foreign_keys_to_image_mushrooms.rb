class AddCameraForeignKeysToImageMushrooms < ActiveRecord::Migration[8.0]
  def change
    add_reference :image_mushrooms, :camera_make, null: true, foreign_key: true
    add_reference :image_mushrooms, :camera_model, null: true, foreign_key: true
  end
end
