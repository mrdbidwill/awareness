class AddLensReferenceToImageMushrooms < ActiveRecord::Migration[8.0]
  def change
    add_reference :image_mushrooms, :lens, null: true, foreign_key: true
  end
end
