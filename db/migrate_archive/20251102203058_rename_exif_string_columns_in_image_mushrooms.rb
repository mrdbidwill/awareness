class RenameExifStringColumnsInImageMushrooms < ActiveRecord::Migration[8.0]
  def change
    # Rename EXIF string columns to avoid conflicts with belongs_to associations
    # camera_make -> exif_make
    # camera_model -> exif_model
    # lens -> exif_lens

    rename_column :image_mushrooms, :camera_make, :exif_make
    rename_column :image_mushrooms, :camera_model, :exif_model
    rename_column :image_mushrooms, :lens, :exif_lens
  end
end
