# test/models/role_test.rb
require "test_helper"

class RoleTest < ActiveSupport::TestCase
  def setup
    @role = roles(:admin)
  end

  # === Validations ===

  test "should be valid with valid attributes" do
    assert @role.valid?
  end

  # === Associations ===

  test "should have many user_roles" do
    assert_respond_to @role, :user_roles
  end

  test "should have many users through user_roles" do
    assert_respond_to @role, :users
  end

  test "should have many role_permissions" do
    assert_respond_to @role, :role_permissions
  end

  test "should have many permissions through role_permissions" do
    assert_respond_to @role, :permissions
  end

  test "should return correct users through association" do
    user = users(:one)
    UserRole.create!(user: user, role: @role)

    assert_includes @role.users, user
  end

  test "should return correct permissions through association" do
    permission = permissions(:admin)
    RolePermission.create!(role: @role, permission: permission)

    assert_includes @role.permissions, permission
  end

  # === Dependent Associations ===

  test "should not destroy role when user_roles exist due to foreign key constraint" do
    user = users(:one)
    UserRole.create!(user: user, role: @role)

    # Foreign key constraint should prevent deletion
    assert_raises(ActiveRecord::InvalidForeignKey) do
      @role.destroy
    end
  end

  # === Business Logic ===

  test "should have name attribute" do
    assert_respond_to @role, :name
    assert_not_nil @role.name
  end

  test "should have description attribute" do
    assert_respond_to @role, :description
  end

  test "should have comments attribute" do
    assert_respond_to @role, :comments
  end

  test "should have timestamps" do
    assert_not_nil @role.created_at
    assert_not_nil @role.updated_at
  end

  # === Multiple Associations ===

  test "should allow multiple users for same role" do
    user1 = users(:one)
    user2 = users(:two)

    UserRole.create!(user: user1, role: @role)
    UserRole.create!(user: user2, role: @role)

    assert_equal 2, @role.users.count
    assert_includes @role.users, user1
    assert_includes @role.users, user2
  end

  test "should allow multiple permissions for same role" do
    perm1 = permissions(:admin)
    perm2 = permissions(:member)

    RolePermission.create!(role: @role, permission: perm1)
    RolePermission.create!(role: @role, permission: perm2)

    assert_equal 2, @role.permissions.count
    assert_includes @role.permissions, perm1
    assert_includes @role.permissions, perm2
  end

  # === CRUD Operations ===

  test "should create new role" do
    assert_difference "Role.count", 1 do
      Role.create!(name: "New Role", description: "Test role")
    end
  end

  test "should update role attributes" do
    @role.update(name: "Updated Role")
    assert_equal "Updated Role", @role.reload.name
  end

  test "should delete role" do
    role = Role.create!(name: "Deletable Role")
    assert_difference "Role.count", -1 do
      role.destroy
    end
  end
end
