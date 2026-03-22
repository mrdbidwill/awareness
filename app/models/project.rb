class Project < ApplicationRecord
  # Projects can be either:
  # 1. Universal (user_id = nil) - Created by admins, available to all users
  # 2. User-specific (user_id present) - Created by individual users for their own use
  belongs_to :user, optional: true
  has_many :mushroom_projects, dependent: :destroy
  has_many :mushrooms, through: :mushroom_projects

  validates :name, presence: true, length: { maximum: 255 }, uniqueness: { case_sensitive: false }

  # Scopes
  scope :universal, -> { where(user_id: nil) }
  scope :user_specific, ->(user) { where(user_id: user.id) }
  scope :available_to, ->(user) { where("user_id IS NULL OR user_id = ?", user.id).order(:name) }

  # Whether this project can be deleted
  def can_be_deleted?
    true
  end

  # Check if project is universal (available to all users)
  def universal?
    user_id.nil?
  end
end