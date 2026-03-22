class Genus < ApplicationRecord
  self.table_name = "genera"

  has_many :genus_mushrooms, dependent: :destroy
  has_many :mushrooms, through: :genus_mushrooms
  has_many :species, foreign_key: :genera_id, dependent: :destroy
end
