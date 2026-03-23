# This migration creates the `articles` table.
class CreateArticles < ActiveRecord::Migration[8.0]
  def change
    create_table :articles do |t|
      t.string   :title, null: false
      t.string   :slug,  null: false
      t.string   :subject
      t.text     :summary
      t.text     :body, null: false
      t.datetime :published_at, index: true
      t.boolean  :published, default: true, null: false

      t.timestamps
    end

    add_index :articles, :slug, unique: true
    add_index :articles, :subject
  end
end