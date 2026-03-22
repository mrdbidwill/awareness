class MushroomSpecies < ApplicationRecord
  belongs_to :mushroom
  belongs_to :species

  validates :species_id, presence: true
  validates :mushroom_id, presence: true
end
