class AddCommentsToImageMushrooms < ActiveRecord::Migration[8.0]
  def change
    add_column :image_mushrooms, :comments, :text
  end
end
