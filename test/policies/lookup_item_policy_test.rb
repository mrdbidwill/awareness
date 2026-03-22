require 'test_helper'

class LookupItemPolicyTest < ActiveSupport::TestCase
  setup do
    @admin_user = users(:one)
    @regular_user = users(:two)
    @lookup_item = LookupItem.new(name: "Test Item")
  end

  test "should authorize admin to view index" do
    assert Pundit.policy(@admin_user, LookupItem).index?
  end

  test "should not authorize regular user to view index" do
    assert_not Pundit.policy(@regular_user, LookupItem).index?
  end

  test "should not authorize nil user to view index" do
    assert_not Pundit.policy(nil, LookupItem).index?
  end

  test "should authorize admin to show" do
    assert Pundit.policy(@admin_user, @lookup_item).show?
  end

  test "should not authorize regular user to show" do
    assert_not Pundit.policy(@regular_user, @lookup_item).show?
  end

  test "should authorize admin to new" do
    assert Pundit.policy(@admin_user, LookupItem.new).new?
  end

  test "should not authorize regular user to new" do
    assert_not Pundit.policy(@regular_user, LookupItem.new).new?
  end

  test "should authorize admin to create" do
    assert Pundit.policy(@admin_user, LookupItem.new).create?
  end

  test "should not authorize regular user to create" do
    assert_not Pundit.policy(@regular_user, LookupItem.new).create?
  end

  test "should authorize admin to edit" do
    assert Pundit.policy(@admin_user, @lookup_item).edit?
  end

  test "should not authorize regular user to edit" do
    assert_not Pundit.policy(@regular_user, @lookup_item).edit?
  end

  test "should authorize admin to update" do
    assert Pundit.policy(@admin_user, @lookup_item).update?
  end

  test "should not authorize regular user to update" do
    assert_not Pundit.policy(@regular_user, @lookup_item).update?
  end

  test "should authorize admin to destroy" do
    assert Pundit.policy(@admin_user, @lookup_item).destroy?
  end

  test "should not authorize regular user to destroy" do
    assert_not Pundit.policy(@regular_user, @lookup_item).destroy?
  end
end
