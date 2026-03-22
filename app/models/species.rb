class Species < ApplicationRecord
  belongs_to :genus, class_name: "Genus", foreign_key: "genera_id"
  has_many :mushroom_species, class_name: "MushroomSpecies", dependent: :destroy
  has_many :mushrooms, through: :mushroom_species
end

