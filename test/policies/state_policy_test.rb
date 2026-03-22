require 'test_helper'

class StatePolicyTest < ActiveSupport::TestCase
  setup do
    @admin_user = users(:one)
    @regular_user = users(:two)
    @state = State.new(name: "Test State")
  end

  test "should authorize admin to view index" do
    assert Pundit.policy(@admin_user, State).index?
  end

  test "should not authorize regular user to view index" do
    assert_not Pundit.policy(@regular_user, State).index?
  end

  test "should not authorize nil user to view index" do
    assert_not Pundit.policy(nil, State).index?
  end

  test "should authorize admin to show" do
    assert Pundit.policy(@admin_user, @state).show?
  end

  test "should not authorize regular user to show" do
    assert_not Pundit.policy(@regular_user, @state).show?
  end

  test "should authorize admin to new" do
    assert Pundit.policy(@admin_user, State.new).new?
  end

  test "should not authorize regular user to new" do
    assert_not Pundit.policy(@regular_user, State.new).new?
  end

  test "should authorize admin to create" do
    assert Pundit.policy(@admin_user, State.new).create?
  end

  test "should not authorize regular user to create" do
    assert_not Pundit.policy(@regular_user, State.new).create?
  end

  test "should authorize admin to edit" do
    assert Pundit.policy(@admin_user, @state).edit?
  end

  test "should not authorize regular user to edit" do
    assert_not Pundit.policy(@regular_user, @state).edit?
  end

  test "should authorize admin to update" do
    assert Pundit.policy(@admin_user, @state).update?
  end

  test "should not authorize regular user to update" do
    assert_not Pundit.policy(@regular_user, @state).update?
  end

  test "should authorize admin to destroy" do
    assert Pundit.policy(@admin_user, @state).destroy?
  end

  test "should not authorize regular user to destroy" do
    assert_not Pundit.policy(@regular_user, @state).destroy?
  end
end
