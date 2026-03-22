# app/models/mushroom.rb
# frozen_string_literal: true

class Mushroom < ApplicationRecord
  # Prevent mass-assignment or runtime changes to the id
  attr_readonly :id

  before_update :prevent_id_change
  after_save :invalidate_comparisons_on_character_change

  belongs_to :user
  belongs_to :country
  belongs_to :state, optional: true
  belongs_to :fungus_type
  belongs_to :mushroom_storage_location, optional: true

  has_many :all_group_mushrooms, dependent: :destroy
  has_many :all_groups, through: :all_group_mushrooms

  has_many :cluster_mushrooms, dependent: :destroy
  has_many :clusters, through: :cluster_mushrooms

  has_many :genus_mushrooms, dependent: :destroy
  has_many :genera, through: :genus_mushrooms

  has_many :mushroom_species, class_name: 'MushroomSpecies', dependent: :destroy
  has_many :species, through: :mushroom_species

  has_many :mushroom_trees, dependent: :destroy
  has_many :trees, through: :mushroom_trees

  has_many :mushroom_plants, dependent: :destroy
  has_many :plants, through: :mushroom_plants

  has_many :mushroom_projects, dependent: :destroy
  has_many :projects, through: :mushroom_projects

  has_many :mr_character_mushrooms, dependent: :destroy
  has_many :mr_characters, through: :mr_character_mushrooms

  has_many :image_mushrooms, dependent: :destroy
  has_many :images, through: :image_mushrooms

  has_many :mushroom_comparisons, dependent: :destroy
  has_many :compared_mushrooms, through: :mushroom_comparisons

  # Scopes
  scope :with_minimum_characters, ->(min_count = 10) {
    joins(:mr_character_mushrooms)
      .group('mushrooms.id')
      .having('COUNT(mr_character_mushrooms.id) >= ?', min_count)
  }
  scope :search_by_name, ->(query) { where("name LIKE ?", "%#{query}%") }
  scope :templates, -> { where(is_template: true) }
  scope :non_templates, -> { where(is_template: false) }
  scope :templates_for_fungus_type, ->(fungus_type_id) {
    where(is_template: true, fungus_type_id: fungus_type_id)
  }

  # Advanced search using MySQL full-text search
  scope :fulltext_search, ->(query) {
    return none if query.blank?
    where("MATCH(name, description, comments) AGAINST(? IN NATURAL LANGUAGE MODE)", query)
  }

  # Search by character values
  scope :with_character, ->(character_id, value = nil) {
    joins(:mr_character_mushrooms)
      .where(mr_character_mushrooms: { mr_character_id: character_id })
      .then { |relation| value.present? ? relation.where(mr_character_mushrooms: { character_value: value }) : relation }
  }

  # Filter by multiple characters (AND logic)
  scope :with_characters, ->(character_filters) {
    return all if character_filters.blank?

    relation = all
    character_filters.each do |char_id, value|
      relation = relation.with_character(char_id, value)
    end
    relation
  }

  validates :name, presence: true, length: { maximum: 255 }, uniqueness: { scope: :user_id, message: :unique }
  validates :country_id, presence: true
  validates :fungus_type_id, presence: true
  validates :description, length: { maximum: 4096 }
  validates :comments, length: { maximum: 4096 }
  validates :city, length: { maximum: 255 }
  validates :county, length: { maximum: 255 }

  # Instance method to trigger comparison recalculation
  def recalculate_comparisons
    CompareMushroomsJob.perform_later(id) if mr_character_mushrooms.count >= CompareMushroomsJob::MINIMUM_CHARACTERS
  end

  # Clone character data from another mushroom or template
  def clone_characters_from(source_mushroom)
    return false unless source_mushroom.is_a?(Mushroom)

    ActiveRecord::Base.transaction do
      source_mushroom.mr_character_mushrooms.each do |source_char_mushroom|
        # Skip if this mushroom already has this character
        next if mr_character_mushrooms.exists?(mr_character_id: source_char_mushroom.mr_character_id)

        # Create a new character entry for this mushroom
        mr_character_mushrooms.create!(
          mr_character_id: source_char_mushroom.mr_character_id,
          character_value: source_char_mushroom.character_value
        )
      end
    end

    true
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error("Failed to clone characters: #{e.message}")
    false
  end

  # Make this mushroom a template
  def make_template!(name, description = nil)
    update!(
      is_template: true,
      template_name: name,
      template_description: description
    )
  end

  # Returns genus/species combinations ranked by is_primary status
  # Primary identifications come first, then ordered by creation date
  # Returns array of hashes: [{ genus: Genus, species: Species, genus_primary: bool, species_primary: bool }, ...]
  def ranked_identifications
    # Get genus_mushrooms with their is_primary status, ordered by primary first, then creation
    genus_records = genus_mushrooms
                      .includes(:genus)
                      .order(Arel.sql('CASE WHEN is_primary = true THEN 0 ELSE 1 END'), :created_at)

    # Get mushroom_species with their is_primary status, ordered by primary first, then creation
    # CRITICAL: Must include species.genus to prevent strict_loading violations in views
    species_records = mushroom_species
                        .includes(species: :genus)
                        .order(Arel.sql('CASE WHEN is_primary = true THEN 0 ELSE 1 END'), :created_at)

    # Pair them up (genus[0] with species[0], genus[1] with species[1], etc.)
    max_count = [genus_records.size, species_records.size].max
    identifications = []

    max_count.times do |i|
      genus_record = genus_records[i]
      species_record = species_records[i]

      # Only add if at least one exists
      if genus_record || species_record
        identifications << {
          genus: genus_record&.genus,
          species: species_record&.species,
          genus_primary: genus_record&.is_primary || false,
          species_primary: species_record&.is_primary || false,
          fully_primary: (genus_record&.is_primary && species_record&.is_primary) || false
        }
      end
    end

    identifications
  end

  private

  def prevent_id_change
    if will_save_change_to_id?
      errors.add(:id, "cannot be changed")
      throw :abort
    end
  end

  def invalidate_comparisons_on_character_change
    # Delete existing comparisons involving this mushroom to force recalculation
    # This is triggered when the mushroom is saved, but we only want to invalidate
    # if character data might have changed (which happens via mr_character_mushrooms)
    # Note: This is a simple approach. For optimization, you could check if
    # mr_character_mushrooms changed before invalidating.
    MushroomComparison.involving_mushroom(id).destroy_all if saved_change_to_updated_at?
  end
end
