class MushroomPlant < ApplicationRecord
  belongs_to :plant
  belongs_to :mushroom, counter_cache: :plants_count

  validates :plant_id, uniqueness: { scope: :mushroom_id, message: "is already associated with this mushroom" }
end
