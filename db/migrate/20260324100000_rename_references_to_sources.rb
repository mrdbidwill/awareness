# frozen_string_literal: true

class RenameReferencesToSources < ActiveRecord::Migration[8.0]
  def up
    if table_exists?(:references) && !table_exists?(:sources)
      rename_table :references, :sources
    elsif !table_exists?(:sources)
      return
    end

    rename_index :sources, "index_references_on_name", "index_sources_on_name" if index_name_exists?(:sources, "index_references_on_name")
    rename_index :sources, "index_references_on_publish_date", "index_sources_on_publish_date" if index_name_exists?(:sources, "index_references_on_publish_date")
  end

  def down
    return unless table_exists?(:sources) || table_exists?(:references)

    if table_exists?(:sources)
      rename_index :sources, "index_sources_on_name", "index_references_on_name" if index_name_exists?(:sources, "index_sources_on_name")
      rename_index :sources, "index_sources_on_publish_date", "index_references_on_publish_date" if index_name_exists?(:sources, "index_sources_on_publish_date")

      rename_table :sources, :references unless table_exists?(:references)
    end
  end
end
