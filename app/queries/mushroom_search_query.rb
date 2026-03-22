# frozen_string_literal: true

# Query object for searching and filtering mushrooms.
#
# Handles complex search logic including:
# - Full-text search
# - Fungus type filtering
# - Character-based filtering
# - Geographic filtering
# - Eager loading for performance
#
# Usage:
#   mushrooms = MushroomSearchQuery.new(policy_scope(Mushroom))
#                 .search(params[:q])
#                 .by_fungus_type(params[:fungus_type_id])
#                 .by_characters(params[:characters])
#                 .with_associations
#                 .results
#                 .page(params[:page])
class MushroomSearchQuery < ApplicationQuery
  def initialize(scope = Mushroom.all)
    super(scope)
  end

  # Apply full-text search on collection name
  def search(term)
    return self if term.blank?

    @scope = @scope.fulltext_search(term)
    self
  end

  # Filter by fungus type
  def by_fungus_type(fungus_type_id)
    return self if fungus_type_id.blank?

    @scope = @scope.where(fungus_type_id: fungus_type_id)
    self
  end

  # Filter by character attributes
  # Expects hash like: { "1" => ["color_id:5"], "2" => ["color_id:3"] }
  def by_characters(character_filters)
    return self if character_filters.blank?

    character_filters.each do |mr_character_id, values|
      next if values.blank?

      # Ensure values is an array
      values = Array(values)

      values.each do |value|
        if value.include?("color_id:")
          color_id = value.split(":").last
          @scope = @scope.joins(:mr_character_mushrooms)
                        .where(
                          mr_character_mushrooms: {
                            mr_character_id: mr_character_id
                          }
                        )
                        .where(
                          "EXISTS (SELECT 1 FROM mr_character_mushroom_colors WHERE mr_character_mushroom_colors.mr_character_mushroom_id = mr_character_mushrooms.id AND mr_character_mushroom_colors.color_id = ?)",
                          color_id
                        )
        end
      end
    end

    @scope = @scope.distinct
    self
  end

  # Filter to only non-template mushrooms
  def non_templates
    @scope = @scope.non_templates
    self
  end

  # Filter to mushrooms with minimum character count
  def with_minimum_characters(min_count = 10)
    @scope = @scope.with_minimum_characters(min_count)
    self
  end

  # Filter by state
  def by_state(state_id)
    return self if state_id.blank?

    @scope = @scope.where(state_id: state_id)
    self
  end

  # Filter by country
  def by_country(country_id)
    return self if country_id.blank?

    @scope = @scope.where(country_id: country_id)
    self
  end

  # Eager load associations to prevent N+1 queries
  def with_associations
    @scope = @scope.includes(
      :fungus_type,
      :country,
      :state,
      :genera,
      :species,
      image_mushrooms: [:part, { image_file_attachment: :blob }]
    )
    self
  end

  # Return scope suitable for comparison feature
  def for_comparison
    with_minimum_characters(10)
    with_associations
    self
  end
end
