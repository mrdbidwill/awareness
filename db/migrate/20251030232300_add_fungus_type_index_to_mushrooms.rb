class AddFungusTypeIndexToMushrooms < ActiveRecord::Migration[8.0]
  def change
    add_index :mushrooms, :fungus_type_id unless index_exists?(:mushrooms, :fungus_type_id)
  end
end
