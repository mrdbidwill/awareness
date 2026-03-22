class AllGroupMushroom < ApplicationRecord
  belongs_to :mushroom
  belongs_to :all_group

  # Validation removed to allow fixtures and controller tests to operate without user coupling
  validate :ensure_same_user
  validate :uniqueness_of_all_group_per_mushroom

  private

  def uniqueness_of_all_group_per_mushroom
    if AllGroupMushroom.exists?(all_group_id: all_group_id, mushroom_id: mushroom_id) && new_record?
      errors.add(:base, "This group is already attached to this mushroom")
    end
  end

  def ensure_same_user
    return if mushroom.nil? || all_group.nil? # Skip validation if associations are missing
    if mushroom.user_id != all_group.user_id
      errors.add(:all_group, "must belong to the same user as the mushroom")
    end
  end
end


