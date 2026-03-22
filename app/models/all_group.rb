class AllGroup < ApplicationRecord
  belongs_to :user
  has_many :all_group_mushrooms, dependent: :destroy
  has_many :mushrooms, through: :all_group_mushrooms

  validates :name, presence: true, length: { maximum: 255 }, uniqueness: { scope: :user_id, case_sensitive: false }

  def can_be_deleted?
    true
  end
end

