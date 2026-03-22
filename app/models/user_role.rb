# app/models/user_role.rb
class UserRole < ApplicationRecord
  belongs_to :user
  belongs_to :role

  validates :role_id, uniqueness: { scope: :user_id, message: "is already assigned to this user" }
end
