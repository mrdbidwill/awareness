# frozen_string_literal: true

class AddStorageMetadataAndColorsToImageMushrooms < ActiveRecord::Migration[8.0]
  def change
    add_column :image_mushrooms, :image_storage_key, :string
    add_column :image_mushrooms, :image_public_url, :string
    add_column :image_mushrooms, :image_content_type, :string
    add_column :image_mushrooms, :image_byte_size, :bigint
    add_column :image_mushrooms, :dominant_hex, :string
    add_column :image_mushrooms, :dominant_hue, :integer
    add_column :image_mushrooms, :color_bucket, :string

    add_index :image_mushrooms, :dominant_hue
  end
end
