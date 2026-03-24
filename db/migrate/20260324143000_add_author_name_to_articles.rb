# frozen_string_literal: true

class AddAuthorNameToArticles < ActiveRecord::Migration[8.0]
  def up
    add_column :articles, :author_name, :string unless column_exists?(:articles, :author_name)

    execute <<~SQL.squish
      UPDATE articles
      LEFT JOIN users ON users.id = articles.user_id
      SET articles.author_name = NULLIF(users.display_name, '')
      WHERE articles.author_name IS NULL
    SQL
  end

  def down
    remove_column :articles, :author_name, :string if column_exists?(:articles, :author_name)
  end
end
