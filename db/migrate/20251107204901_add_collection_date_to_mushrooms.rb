class AddCollectionDateToMushrooms < ActiveRecord::Migration[8.0]
  def change
    add_column :mushrooms, :collection_date, :date
  end
end
