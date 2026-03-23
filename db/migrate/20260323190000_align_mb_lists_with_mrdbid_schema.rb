# frozen_string_literal: true

class AlignMbListsWithMrdbidSchema < ActiveRecord::Migration[8.0]
  def up
    return unless table_exists?(:mb_lists)

    remove_column :mb_lists, :created_at, :datetime if column_exists?(:mb_lists, :created_at)
    remove_column :mb_lists, :updated_at, :datetime if column_exists?(:mb_lists, :updated_at)
  end

  def down
    return unless table_exists?(:mb_lists)

    add_timestamps :mb_lists, null: false unless column_exists?(:mb_lists, :created_at) || column_exists?(:mb_lists, :updated_at)
  end
end
