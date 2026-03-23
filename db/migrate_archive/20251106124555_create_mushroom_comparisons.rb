# frozen_string_literal: true

class CreateMushroomComparisons < ActiveRecord::Migration[8.0]
  def change
    create_table :mushroom_comparisons do |t|
      t.references :mushroom, null: false, foreign_key: true
      t.references :compared_mushroom, null: false, foreign_key: { to_table: :mushrooms }
      t.integer :similarity_score, null: false, default: 0, comment: "Percentage similarity 0-100"
      t.integer :matching_characters, null: false, default: 0, comment: "Count of matching character values"
      t.integer :total_characters, null: false, default: 0, comment: "Total unique characters compared"
      t.string :status, null: false, default: 'pending', comment: "pending, completed, failed"
      t.datetime :completed_at
      t.timestamps
    end

    # Composite index for fast lookups of comparisons for a specific mushroom
    add_index :mushroom_comparisons, [:mushroom_id, :similarity_score],
              name: 'index_comparisons_on_mushroom_and_score',
              order: { similarity_score: :desc }

    # Prevent duplicate comparisons (A vs B = B vs A)
    add_index :mushroom_comparisons, [:mushroom_id, :compared_mushroom_id],
              unique: true,
              name: 'index_comparisons_on_mushroom_pair'

    # Index for finding all comparisons involving a mushroom (either direction)
    add_index :mushroom_comparisons, :compared_mushroom_id,
              name: 'index_comparisons_on_compared_mushroom'

    # Index for filtering by status
    add_index :mushroom_comparisons, :status,
              name: 'index_comparisons_on_status'
  end
end
