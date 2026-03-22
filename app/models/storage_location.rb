class StorageLocation < ApplicationRecord
  has_many :mushrooms

  validates :name, presence: true
end

