class MushroomTree < ApplicationRecord
  belongs_to :tree
  belongs_to :mushroom, counter_cache: :trees_count

  validates :tree_id, uniqueness: { scope: :mushroom_id, message: "is already associated with this mushroom" }
end
