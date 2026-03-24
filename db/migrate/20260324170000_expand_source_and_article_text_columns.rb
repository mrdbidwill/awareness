# frozen_string_literal: true

class ExpandSourceAndArticleTextColumns < ActiveRecord::Migration[8.0]
  LONGTEXT_LIMIT = 4_294_967_295

  def up
    if table_exists?(:sources)
      change_column :sources, :author, :text, limit: LONGTEXT_LIMIT if column_exists?(:sources, :author)
      change_column :sources, :description, :text, limit: LONGTEXT_LIMIT if column_exists?(:sources, :description)
    end

    return unless table_exists?(:articles)

    change_column :articles, :body, :text, limit: LONGTEXT_LIMIT if column_exists?(:articles, :body)
  end

  def down
    if table_exists?(:sources)
      change_column :sources, :author, :string if column_exists?(:sources, :author)
      change_column :sources, :description, :text if column_exists?(:sources, :description)
    end

    return unless table_exists?(:articles)

    change_column :articles, :body, :text if column_exists?(:articles, :body)
  end
end
