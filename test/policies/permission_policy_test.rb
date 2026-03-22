require 'test_helper'

class PermissionPolicyTest < ActiveSupport::TestCase
  setup do
    @admin_user = users(:one)
    @regular_user = users(:two)
    @permission = Permission.new(name: "Test Permission")
  end

  test "should authorize admin to view index" do
    assert Pundit.policy(@admin_user, Permission).index?
  end

  test "should not authorize regular user to view index" do
    assert_not Pundit.policy(@regular_user, Permission).index?
  end

  test "should not authorize nil user to view index" do
    assert_not Pundit.policy(nil, Permission).index?
  end

  test "should authorize admin to show" do
    assert Pundit.policy(@admin_user, @permission).show?
  end

  test "should not authorize regular user to show" do
    assert_not Pundit.policy(@regular_user, @permission).show?
  end

  test "should authorize admin to new" do
    assert Pundit.policy(@admin_user, Permission.new).new?
  end

  test "should not authorize regular user to new" do
    assert_not Pundit.policy(@regular_user, Permission.new).new?
  end

  test "should authorize admin to create" do
    assert Pundit.policy(@admin_user, Permission.new).create?
  end

  test "should not authorize regular user to create" do
    assert_not Pundit.policy(@regular_user, Permission.new).create?
  end

  test "should authorize admin to edit" do
    assert Pundit.policy(@admin_user, @permission).edit?
  end

  test "should not authorize regular user to edit" do
    assert_not Pundit.policy(@regular_user, @permission).edit?
  end

  test "should authorize admin to update" do
    assert Pundit.policy(@admin_user, @permission).update?
  end

  test "should not authorize regular user to update" do
    assert_not Pundit.policy(@regular_user, @permission).update?
  end

  test "should authorize admin to destroy" do
    assert Pundit.policy(@admin_user, @permission).destroy?
  end

  test "should not authorize regular user to destroy" do
    assert_not Pundit.policy(@regular_user, @permission).destroy?
  end
end
