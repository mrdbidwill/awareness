# frozen_string_literal: true

class MushroomComparison < ApplicationRecord
  # ============================================================================
  # MUSHROOM COMPARISON MODEL
  # ============================================================================
  # Stores pre-computed similarity scores between mushroom pairs.
  # Comparisons are computed asynchronously via CompareMushroomsJob.
  #
  # RELATIONSHIPS:
  # - mushroom: The primary mushroom being compared
  # - compared_mushroom: The mushroom being compared against
  #
  # SIMILARITY SCORING:
  # - Uses Jaccard similarity: |A ∩ B| / |A ∪ B|
  # - Stored as integer percentage (0-100) for performance
  # - Based on matching character_value in mr_character_mushrooms
  #
  # STATUS VALUES:
  # - pending: Comparison queued but not yet processed
  # - completed: Comparison successfully computed
  # - failed: Comparison failed due to error
  # ============================================================================

  belongs_to :mushroom
  belongs_to :compared_mushroom, class_name: 'Mushroom'

  # Validations
  validates :similarity_score, presence: true,
                               numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :matching_characters, presence: true,
                                  numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :total_characters, presence: true,
                               numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :status, presence: true, inclusion: { in: %w[pending completed failed] }
  validates :compared_mushroom_id, uniqueness: { scope: :mushroom_id,
                                                  message: "comparison already exists for this mushroom pair" }
  validate :different_mushrooms

  # Scopes
  scope :completed, -> { where(status: 'completed') }
  scope :pending, -> { where(status: 'pending') }
  scope :failed, -> { where(status: 'failed') }
  scope :for_mushroom, ->(mushroom_id) { where(mushroom_id: mushroom_id) }
  scope :by_similarity, -> { order(similarity_score: :desc) }
  scope :high_similarity, ->(threshold = 50) { where('similarity_score >= ?', threshold) }

  # Get all comparisons involving a mushroom (either as primary or compared)
  scope :involving_mushroom, ->(mushroom_id) {
    where('mushroom_id = ? OR compared_mushroom_id = ?', mushroom_id, mushroom_id)
  }

  # Mark comparison as completed
  def mark_completed!(score, matching, total)
    update!(
      status: 'completed',
      similarity_score: score,
      matching_characters: matching,
      total_characters: total,
      completed_at: Time.current
    )
  end

  # Mark comparison as failed
  def mark_failed!
    update!(status: 'failed', completed_at: Time.current)
  end

  private

  def different_mushrooms
    if mushroom_id.present? && compared_mushroom_id.present? && mushroom_id == compared_mushroom_id
      errors.add(:compared_mushroom_id, "must be different from mushroom")
    end
  end
end
