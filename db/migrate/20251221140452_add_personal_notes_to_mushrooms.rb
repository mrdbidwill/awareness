class AddPersonalNotesToMushrooms < ActiveRecord::Migration[8.0]
  def change
    add_column :mushrooms, :personal_notes, :text
  end
end
