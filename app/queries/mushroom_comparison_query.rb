# frozen_string_literal: true

# Query object for finding similar mushrooms based on character comparisons.
#
# Handles:
# - Finding mushrooms with overlapping characters
# - Calculating similarity scores
# - Filtering by minimum similarity threshold
# - Excluding specific mushrooms
#
# Usage:
#   similar = MushroomComparisonQuery.new(policy_scope(Mushroom))
#               .similar_to(@mushroom)
#               .with_minimum_similarity(0.7)
#               .excluding(@mushroom)
#               .results
class MushroomComparisonQuery < ApplicationQuery
  def initialize(scope = Mushroom.all)
    super(scope)
  end

  # Find mushrooms similar to the given mushroom based on character overlap
  def similar_to(mushroom)
    character_ids = mushroom.mr_character_mushrooms.pluck(:mr_character_id)
    return self if character_ids.empty?

    @scope = @scope
              .joins(:mr_character_mushrooms)
              .where(mr_character_mushrooms: { mr_character_id: character_ids })
              .group('mushrooms.id')
              .select('mushrooms.*, COUNT(DISTINCT mr_character_mushrooms.mr_character_id) as matching_characters')
              .having('COUNT(DISTINCT mr_character_mushrooms.mr_character_id) > 0')
    self
  end

  # Filter by minimum number of matching characters
  def with_minimum_matches(min_matches)
    @scope = @scope.having('COUNT(DISTINCT mr_character_mushrooms.mr_character_id) >= ?', min_matches)
    self
  end

  # Exclude specific mushroom IDs
  def excluding(*mushroom_ids)
    mushroom_ids = mushroom_ids.flatten.compact
    return self if mushroom_ids.empty?

    @scope = @scope.where.not(id: mushroom_ids)
    self
  end

  # Order by similarity (most matching characters first)
  def by_similarity
    @scope = @scope.order('matching_characters DESC')
    self
  end

  # Limit to top N most similar
  def top(limit)
    @scope = @scope.limit(limit)
    self
  end
end
