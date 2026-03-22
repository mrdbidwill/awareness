# test/models/role_permission_test.rb
require "test_helper"

class RolePermissionTest < ActiveSupport::TestCase
  def setup
    @role = roles(:admin)
    @permission = permissions(:admin)
    @role_permission = RolePermission.create!(role: @role, permission: @permission)
  end

  # === Validations ===

  test "should be valid with valid attributes" do
    assert @role_permission.valid?
  end

  test "should require role" do
    @role_permission.role = nil
    assert_not @role_permission.valid?
    assert_includes @role_permission.errors[:role], "must exist"
  end

  test "should require permission" do
    @role_permission.permission = nil
    assert_not @role_permission.valid?
    assert_includes @role_permission.errors[:permission], "must exist"
  end

  # === Associations ===

  test "should belong to role" do
    assert_respond_to @role_permission, :role
    assert_instance_of Role, @role_permission.role
  end

  test "should belong to permission" do
    assert_respond_to @role_permission, :permission
    assert_instance_of Permission, @role_permission.permission
  end

  # === Uniqueness ===

  test "should allow same role with different permissions" do
    permission2 = permissions(:member)
    role_permission2 = RolePermission.new(role: @role, permission: permission2)
    assert role_permission2.valid?
    assert role_permission2.save
  end

  test "should allow same permission for different roles" do
    role2 = roles(:manager)
    role_permission2 = RolePermission.new(role: role2, permission: @permission)
    assert role_permission2.valid?
    assert role_permission2.save
  end

  test "should prevent duplicate role-permission combination" do
    duplicate = RolePermission.new(role: @role, permission: @permission)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:permission_id], "is already assigned to this role"
  end

  # === CRUD Operations ===

  test "should create role_permission" do
    role = roles(:manager)
    permission = permissions(:member)

    assert_difference "RolePermission.count", 1 do
      RolePermission.create!(role: role, permission: permission)
    end
  end

  test "should destroy role_permission" do
    assert_difference "RolePermission.count", -1 do
      @role_permission.destroy
    end
  end

  test "should have timestamps" do
    assert_not_nil @role_permission.created_at
    assert_not_nil @role_permission.updated_at
  end

  # === Business Logic ===

  test "should allow multiple permissions per role" do
    permission2 = permissions(:member)
    # Clean up any existing admin role + member permission
    RolePermission.where(role: @role, permission: permission2).destroy_all
    RolePermission.create!(role: @role, permission: permission2)

    # Count should be at least 2
    assert @role.role_permissions.count >= 2, "Role should have at least 2 permissions"
    assert_includes @role.permissions, @permission
    assert_includes @role.permissions, permission2
  end

  test "should allow multiple roles per permission" do
    role2 = roles(:manager)
    # Clean up any existing manager role + admin permission
    RolePermission.where(role: role2, permission: @permission).destroy_all
    RolePermission.create!(role: role2, permission: @permission)

    # Count should be at least 2
    assert @permission.role_permissions.count >= 2, "Permission should have at least 2 roles"
    assert_includes @permission.roles, @role
    assert_includes @permission.roles, role2
  end

  # === Edge Cases ===

  test "should not allow nil role_id" do
    role_permission = RolePermission.new(permission: @permission)
    assert_not role_permission.valid?
  end

  test "should not allow nil permission_id" do
    role_permission = RolePermission.new(role: @role)
    assert_not role_permission.valid?
  end

  test "should handle invalid role_id" do
    role_permission = RolePermission.new(role_id: 999999, permission: @permission)
    assert_not role_permission.valid?
  end

  test "should handle invalid permission_id" do
    role_permission = RolePermission.new(role: @role, permission_id: 999999)
    assert_not role_permission.valid?
  end

  # === Complex Scenarios ===

  test "admin role can have multiple permission levels" do
    admin_role = roles(:admin)
    perm1 = permissions(:admin)
    perm2 = permissions(:member)

    # Clean up any existing combinations from setup/fixtures
    RolePermission.where(role: admin_role, permission: perm1).destroy_all
    RolePermission.where(role: admin_role, permission: perm2).destroy_all

    RolePermission.create!(role: admin_role, permission: perm1)
    RolePermission.create!(role: admin_role, permission: perm2)

    assert admin_role.permissions.include?(perm1)
    assert admin_role.permissions.include?(perm2)
  end

  test "one permission can be assigned to multiple roles" do
    admin_perm = permissions(:admin)
    role1 = roles(:admin)
    role2 = roles(:manager)

    # Clean up any existing combinations from setup/fixtures
    RolePermission.where(role: role1, permission: admin_perm).destroy_all
    RolePermission.where(role: role2, permission: admin_perm).destroy_all

    RolePermission.create!(role: role1, permission: admin_perm)
    RolePermission.create!(role: role2, permission: admin_perm)

    # Check actual count (may include fixture data)
    assert admin_perm.roles.reload.count >= 2, "Permission should have at least 2 roles"
  end
end
