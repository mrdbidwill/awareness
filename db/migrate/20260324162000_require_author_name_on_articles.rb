# frozen_string_literal: true

class RequireAuthorNameOnArticles < ActiveRecord::Migration[8.0]
  def up
    execute <<~SQL.squish
      UPDATE articles
      LEFT JOIN users ON users.id = articles.user_id
      SET articles.author_name = NULLIF(users.display_name, '')
      WHERE articles.author_name IS NULL OR articles.author_name = ''
    SQL

    execute <<~SQL.squish
      UPDATE articles
      SET author_name = 'Unknown author'
      WHERE author_name IS NULL OR author_name = ''
    SQL

    change_column_null :articles, :author_name, false
  end

  def down
    change_column_null :articles, :author_name, true
  end
end
