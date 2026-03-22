class Color < ApplicationRecord
  has_many :mr_character_mushroom_colors, dependent: :destroy, strict_loading: false
  has_many :mr_character_mushrooms, through: :mr_character_mushroom_colors

  validates :latin_name, :common_name, presence: true

  # Scope to order colors by their sequence in the AMS chart
  scope :by_sequence, -> { order(sequence: :asc) }

  # Scope to find colors by group
  scope :by_group, ->(group) { where(color_group: group) }

  # Scopes for simplified color system
  scope :simplified, -> { where(is_simplified: true) }
  scope :legacy_ams, -> { where(is_simplified: false) }
  scope :by_family, ->(family) { where(color_family: family) }
  scope :by_display_order, -> { order(display_order: :asc) }

  # Scope for color picker - shows all colors in a sensible order
  # Simplified colors first (by display_order), then AMS colors (by sequence)
  scope :all_for_picker, -> {
    order(Arel.sql('CASE WHEN is_simplified = 1 THEN 0 ELSE 1 END, COALESCE(display_order, sequence)'))
  }

  # Get all color families in display order
  def self.color_families
    simplified.select(:color_family).distinct.pluck(:color_family)
  end

  # Get colors grouped by family
  def self.grouped_by_family
    simplified.by_display_order.group_by(&:color_family)
  end

  # Find the simplified equivalent of a legacy AMS color
  def simplified_equivalent
    return self if is_simplified?
    Color.find_by(id: simplified_color_id) if simplified_color_id.present?
  end

  # Check if this is a simplified color
  def is_simplified?
    is_simplified == true
  end
end
