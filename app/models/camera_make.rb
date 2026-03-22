class CameraMake < ApplicationRecord
  has_many :cameras, dependent: :nullify

  validates :name, presence: true, uniqueness: true
end
