class CameraModel < ApplicationRecord
  has_many :cameras, dependent: :nullify

  validates :name, presence: true
end
