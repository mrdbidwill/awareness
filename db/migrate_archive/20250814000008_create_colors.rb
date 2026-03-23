class CreateColors < ActiveRecord::Migration[8.0]
  def change
    create_table :colors do |t|
      t.string :latin_name, null: false
      t.string :common_name
      t.integer :color_group
      t.string :hex, null: false
      t.integer :sequence
      t.integer :r_val, null: false
      t.integer :g_val, null: false
      t.integer :b_val, null: false
      t.string :closest_websafe_color
      t.string :cwc_r
      t.string :cwc_g
      t.string :cwc_b
      t.string :image_file_address, null: false, default: 'default_image_path.jpg' # Ensure consistent paths
      t.json :metadata
      t.timestamps
    end

    add_index :colors, :latin_name, unique: true
    add_index :colors, :hex, unique: true
  end
end
