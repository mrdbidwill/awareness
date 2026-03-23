class AddDateTakenToImageMushrooms < ActiveRecord::Migration[8.0]
  def change
    add_column :image_mushrooms, :date_taken, :datetime
  end
end
