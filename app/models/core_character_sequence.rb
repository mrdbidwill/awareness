class CoreCharacterSequence < ApplicationRecord
  belongs_to :mr_character
  belongs_to :fungus_type

  validates :sequence, numericality: { only_integer: true, allow_nil: false }
  validates :mr_character_id, uniqueness: { scope: :fungus_type_id }
end
