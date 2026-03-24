# frozen_string_literal: true

class CreateArticleSourceCitations < ActiveRecord::Migration[8.0]
  def change
    create_table :article_source_citations do |t|
      t.references :article, null: false, foreign_key: { on_delete: :cascade }
      t.references :source, null: false, foreign_key: { on_delete: :cascade }
      t.string :page_locator
      t.text :note
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    add_index :article_source_citations, [:article_id, :position], name: "index_article_source_citations_on_article_and_position"
  end
end
