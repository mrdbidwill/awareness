# frozen_string_literal: true

class MrCharacterMushroomColor < ApplicationRecord
  belongs_to :mr_character_mushroom
  belongs_to :color

  validates :display_order, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :color_id, uniqueness: { scope: :mr_character_mushroom_id, message: "already added to this character" }

  # Scope to get colors in display order
  scope :ordered, -> { order(:display_order) }
  scope :primary, -> { where(display_order: 1) }
  scope :secondary, -> { where('display_order > 1').order(:display_order) }
end
