class Tree < ApplicationRecord
  has_many :mushroom_trees, dependent: :destroy
  has_many :mushrooms, through: :mushroom_trees
end