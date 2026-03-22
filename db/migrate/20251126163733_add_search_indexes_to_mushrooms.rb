class AddSearchIndexesToMushrooms < ActiveRecord::Migration[8.0]
  def change
    # Add full-text search index on mushrooms name, description, and comments
    # MySQL supports FULLTEXT indexes for faster text searching
    add_index :mushrooms, [:name, :description, :comments], type: :fulltext, name: 'mushrooms_fulltext_idx'
  end
end
