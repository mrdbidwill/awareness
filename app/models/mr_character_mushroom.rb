class MrCharacterMushroom < ApplicationRecord
  belongs_to :mr_character
  belongs_to :mushroom, counter_cache: true
  has_many :mr_character_mushroom_colors, dependent: :destroy, strict_loading: false
  has_many :colors, through: :mr_character_mushroom_colors

  before_validation :normalize_boolean_character_value, if: :booleanish_display_option?
  after_save :invalidate_mushroom_comparisons
  after_destroy :invalidate_mushroom_comparisons

  validates :character_value, presence: true, unless: :color_character?

  validate :validate_color_presence

  scope :colors_for_mushroom, ->(mushroom_id) {
    joins(:mr_character).where(
      mushroom_id: mushroom_id,
      mr_characters: { display_option_id: 6 }
    ).includes(:mr_character, :colors)
  }

  # Public method - check if this is a color character
  def color_character?
    mr_character&.display_option_id == 6
  end

  # Helper methods for color management
  def ordered_colors
    colors.joins(:mr_character_mushroom_colors)
          .where(mr_character_mushroom_colors: { mr_character_mushroom_id: id })
          .order('mr_character_mushroom_colors.display_order')
          .uniq
  end

  def color_ids
    mr_character_mushroom_colors.ordered.pluck(:color_id)
  end

  def color_ids=(ids)
    # Clear existing colors
    mr_character_mushroom_colors.destroy_all

    # Add new colors with display order
    Array(ids).compact.reject(&:blank?).each_with_index do |color_id, index|
      mr_character_mushroom_colors.build(color_id: color_id, display_order: index + 1)
    end
  end

  def primary_color
    colors.joins(:mr_character_mushroom_colors)
          .where(mr_character_mushroom_colors: { display_order: 1 })
          .first
  end

  def secondary_colors
    colors.joins(:mr_character_mushroom_colors)
          .where('mr_character_mushroom_colors.display_order > 1')
          .order('mr_character_mushroom_colors.display_order')
  end

  private

  def display_value
    if color_character?
      ordered_colors.map(&:latin_name).join(", ")
    else
      character_value
    end
  end

  def booleanish_display_option?
    name = mr_character&.display_option&.name.to_s
    %w[boolean_yes_no boolean_true_false boolean_present_absent checkbox].include?(name)
  end

  def normalize_boolean_character_value
    v = character_value.to_s.strip.downcase
    self.character_value =
      if %w[true yes present y on 1 checked].include?(v)
        "true"
      elsif %w[false no absent n off 0 unchecked].include?(v)
        "false"
      else
        v.presence || "false"
      end
  end

  def validate_color_presence
    if color_character? && mr_character_mushroom_colors.empty?
      errors.add(:base, "At least one color must be selected")
    end
  end

  def invalidate_mushroom_comparisons
    # When a character is added/updated/deleted, invalidate all comparisons involving this mushroom
    MushroomComparison.involving_mushroom(mushroom_id).destroy_all
  end
end

