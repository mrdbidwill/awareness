class AddNeedsReviewToMrCharacters < ActiveRecord::Migration[8.0]
  def change
    add_column :mr_characters, :needs_review, :boolean, default: false, null: false
  end
end
