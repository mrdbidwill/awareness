# test/models/permission_test.rb
require "test_helper"

class PermissionTest < ActiveSupport::TestCase
  def setup
    @permission = permissions(:admin)
  end

  # === Validations ===

  test "should be valid with valid attributes" do
    assert @permission.valid?
  end

  # === Associations ===

  test "should have many role_permissions" do
    assert_respond_to @permission, :role_permissions
  end

  test "should have many roles through role_permissions" do
    assert_respond_to @permission, :roles
  end

  test "should return correct roles through association" do
    role = roles(:admin)
    RolePermission.create!(role: role, permission: @permission)

    assert_includes @permission.roles, role
  end

  # === Attributes ===

  test "should have name attribute" do
    assert_respond_to @permission, :name
    assert_not_nil @permission.name
  end

  test "should have description attribute" do
    assert_respond_to @permission, :description
  end

  test "should have comments attribute" do
    assert_respond_to @permission, :comments
  end

  test "should have timestamps" do
    assert_not_nil @permission.created_at
    assert_not_nil @permission.updated_at
  end

  # === Multiple Associations ===

  test "should allow multiple roles for same permission" do
    role1 = roles(:admin)
    role2 = roles(:manager)

    RolePermission.create!(role: role1, permission: @permission)
    RolePermission.create!(role: role2, permission: @permission)

    assert_equal 2, @permission.roles.count
    assert_includes @permission.roles, role1
    assert_includes @permission.roles, role2
  end

  # === CRUD Operations ===

  test "should create new permission" do
    assert_difference "Permission.count", 1 do
      Permission.create!(name: "New Permission", description: "Test permission")
    end
  end

  test "should update permission attributes" do
    @permission.update(name: "Updated Permission")
    assert_equal "Updated Permission", @permission.reload.name
  end

  test "should delete permission" do
    permission = Permission.create!(name: "Deletable Permission")
    assert_difference "Permission.count", -1 do
      permission.destroy
    end
  end

  # === Business Logic ===

  test "should maintain permission id for permission level checking" do
    assert_equal 1, @permission.id, "Admin permission should have id 1"
  end

  test "member permission should have higher id" do
    member_permission = permissions(:member)
    assert_equal 9, member_permission.id, "Member permission should have id 9"
  end
end
