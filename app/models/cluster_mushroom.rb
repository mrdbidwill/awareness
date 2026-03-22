class ClusterMushroom < ApplicationRecord
  belongs_to :mushroom
  belongs_to :cluster

  validates :cluster_id, uniqueness: { scope: :mushroom_id, message: "is already attached to this mushroom" }

  validate :ensure_same_user

  private

  def ensure_same_user
    return if mushroom.nil? || cluster.nil? # Skip validation if associations are missing
    if mushroom.user_id != cluster.user_id
      errors.add(:cluster, "must belong to the same user as the mushroom")
    end
  end
end


