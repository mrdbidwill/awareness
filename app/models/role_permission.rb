# app/models/role_permission.rb
class RolePermission < ApplicationRecord
  belongs_to :role
  belongs_to :permission

  validates :permission_id, uniqueness: { scope: :role_id, message: "is already assigned to this role" }
end
