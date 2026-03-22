class Cluster < ApplicationRecord
  belongs_to :user
  has_many :cluster_mushrooms, dependent: :destroy
  has_many :mushrooms, through: :cluster_mushrooms

  validates :name, presence: true, length: { maximum: 255 }, uniqueness: { scope: :user_id, case_sensitive: false }
end

