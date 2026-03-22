class MushroomProject < ApplicationRecord
  belongs_to :mushroom
  belongs_to :project, counter_cache: true

  validates :project_id, uniqueness: { scope: :mushroom_id, message: "is already attached to this mushroom" }

  # No owner check here by design

  private
end
