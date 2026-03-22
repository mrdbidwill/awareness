class Camera < ApplicationRecord
  belongs_to :camera_make
  belongs_to :camera_model

  validates :name, presence: true
end
