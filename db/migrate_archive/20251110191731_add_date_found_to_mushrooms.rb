class AddDateFoundToMushrooms < ActiveRecord::Migration[8.0]
  def change
    add_column :mushrooms, :date_found, :date
  end
end
