class Plant < ApplicationRecord
  has_many :mushroom_plants, dependent: :destroy
  has_many :mushrooms, through: :mushroom_plants
end
