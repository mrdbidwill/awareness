require 'test_helper'

class AdminTodoPolicyTest < ActiveSupport::TestCase
  setup do
    @admin_user = users(:one)
    # @admin_user already has permission_id: 1 (admin) from fixtures

    @regular_user = users(:two)
    # @regular_user already has permission_id: 9 (member) from fixtures

    @admin_todo = admin_todos(:one)
  end

  test "should authorize admin to view index" do
    assert Pundit.policy(@admin_user, AdminTodo).index?
  end

  test "should not authorize regular user to view index" do
    assert_not Pundit.policy(@regular_user, AdminTodo).index?
  end

  test "should authorize admin to show todo" do
    assert Pundit.policy(@admin_user, @admin_todo).show?
  end

  test "should not authorize regular user to show todo" do
    assert_not Pundit.policy(@regular_user, @admin_todo).show?
  end

  test "should authorize admin to create todo" do
    assert Pundit.policy(@admin_user, AdminTodo.new).create?
  end

  test "should not authorize regular user to create todo" do
    assert_not Pundit.policy(@regular_user, AdminTodo.new).create?
  end

  test "should authorize admin to update todo" do
    assert Pundit.policy(@admin_user, @admin_todo).update?
  end

  test "should not authorize regular user to update todo" do
    assert_not Pundit.policy(@regular_user, @admin_todo).update?
  end

  test "should authorize admin to destroy todo" do
    assert Pundit.policy(@admin_user, @admin_todo).destroy?
  end

  test "should not authorize regular user to destroy todo" do
    assert_not Pundit.policy(@regular_user, @admin_todo).destroy?
  end

  test "should authorize admin for new action" do
    assert Pundit.policy(@admin_user, AdminTodo.new).new?
  end

  test "should authorize admin for edit action" do
    assert Pundit.policy(@admin_user, @admin_todo).edit?
  end

  test "policy scope should return all todos for admin" do
    scope = Pundit.policy_scope!(@admin_user, AdminTodo)
    assert_includes scope, admin_todos(:one)
    assert_includes scope, admin_todos(:two)
    assert_includes scope, admin_todos(:three)
  end

  test "policy scope should return no todos for regular user" do
    scope = Pundit.policy_scope!(@regular_user, AdminTodo)
    assert_equal 0, scope.count
  end

  test "should not authorize nil user" do
    assert_not Pundit.policy(nil, AdminTodo).index?
    assert_not Pundit.policy(nil, @admin_todo).show?
    assert_not Pundit.policy(nil, AdminTodo.new).create?
  end
end
