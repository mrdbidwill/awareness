class AddIndexesToPublishedAndCollectedOn < ActiveRecord::Migration[8.0]
  def change
    add_index :articles, :published, if_not_exists: true
    add_index :mushrooms, :collection_date, if_not_exists: true
  end
end
