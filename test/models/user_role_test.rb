# test/models/user_role_test.rb
require "test_helper"

class UserRoleTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @role = roles(:admin)
    @user_role = UserRole.create!(user: @user, role: @role)
  end

  # === Validations ===

  test "should be valid with valid attributes" do
    assert @user_role.valid?
  end

  test "should require user" do
    @user_role.user = nil
    assert_not @user_role.valid?
    assert_includes @user_role.errors[:user], "must exist"
  end

  test "should require role" do
    @user_role.role = nil
    assert_not @user_role.valid?
    assert_includes @user_role.errors[:role], "must exist"
  end

  # === Associations ===

  test "should belong to user" do
    assert_respond_to @user_role, :user
    assert_instance_of User, @user_role.user
  end

  test "should belong to role" do
    assert_respond_to @user_role, :role
    assert_instance_of Role, @user_role.role
  end

  # === Uniqueness ===

  test "should allow same user with different roles" do
    role2 = roles(:manager)
    # Clean up any existing user:one + manager from fixtures
    UserRole.where(user: @user, role: role2).destroy_all
    user_role2 = UserRole.new(user: @user, role: role2)
    assert user_role2.valid?
    assert user_role2.save
  end

  test "should allow same role for different users" do
    user2 = users(:two)
    user_role2 = UserRole.new(user: user2, role: @role)
    assert user_role2.valid?
    assert user_role2.save
  end

  test "should prevent duplicate user-role combination" do
    # setup already created user:one + role:admin via @user_role
    # Verify it exists
    assert UserRole.exists?(user: @user, role: @role)

    # Try to create the same combination again
    duplicate = UserRole.new(user: @user, role: @role)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:role_id], "is already assigned to this user"
  end

  # === CRUD Operations ===

  test "should create user_role" do
    user = users(:two)
    role = roles(:manager)

    assert_difference "UserRole.count", 1 do
      UserRole.create!(user: user, role: role)
    end
  end

  test "should destroy user_role" do
    assert_difference "UserRole.count", -1 do
      @user_role.destroy
    end
  end

  test "should have timestamps" do
    assert_not_nil @user_role.created_at
    assert_not_nil @user_role.updated_at
  end

  # === Cascading Behavior ===

  test "should have dependent destroy configured for user_roles on user" do
    # Verify dependent: :destroy is configured
    reflection = User.reflect_on_association(:user_roles)
    assert_equal :destroy, reflection.options[:dependent], "user_roles should have dependent: :destroy"
  end

  test "should allow multiple roles per user" do
    role2 = roles(:manager)
    # Clean up any existing user:one + manager from fixtures
    UserRole.where(user: @user, role: role2).destroy_all
    UserRole.create!(user: @user, role: role2)

    # Count actual user_roles for this user
    expected_count = @user.user_roles.reload.count
    assert expected_count >= 2, "User should have at least 2 roles"
    assert_includes @user.roles, @role
    assert_includes @user.roles, role2
  end

  test "should allow multiple users per role" do
    user2 = users(:two)
    UserRole.create!(user: user2, role: @role)

    # Count actual user_roles for this role
    expected_count = @role.user_roles.reload.count
    assert expected_count >= 2, "Role should have at least 2 users"
    assert_includes @role.users, @user
    assert_includes @role.users, user2
  end

  # === Edge Cases ===

  test "should not allow nil user_id" do
    user_role = UserRole.new(role: @role)
    assert_not user_role.valid?
  end

  test "should not allow nil role_id" do
    user_role = UserRole.new(user: @user)
    assert_not user_role.valid?
  end

  test "should prevent orphaned user_roles when user is deleted" do
    # Since user has dependent: :destroy on user_roles,
    # user_roles should be deleted when user is deleted
    reflection = User.reflect_on_association(:user_roles)
    assert_equal :destroy, reflection.options[:dependent],
                 "User should destroy user_roles to prevent orphaned records"
  end
end
