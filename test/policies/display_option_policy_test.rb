require 'test_helper'

class DisplayOptionPolicyTest < ActiveSupport::TestCase
  setup do
    @admin_user = users(:one)
    @regular_user = users(:two)
    @display_option = DisplayOption.new(name: "Test Option")
  end

  test "should authorize any user to view index" do
    assert Pundit.policy(@regular_user, DisplayOption).index?
    assert Pundit.policy(@admin_user, DisplayOption).index?
  end

  test "should authorize any user to show" do
    assert Pundit.policy(@regular_user, @display_option).show?
    assert Pundit.policy(@admin_user, @display_option).show?
  end

  test "should authorize admin to new" do
    assert Pundit.policy(@admin_user, DisplayOption.new).new?
  end

  test "should not authorize regular user to new" do
    assert_not Pundit.policy(@regular_user, DisplayOption.new).new?
  end

  test "should authorize admin to create" do
    assert Pundit.policy(@admin_user, DisplayOption.new).create?
  end

  test "should not authorize regular user to create" do
    assert_not Pundit.policy(@regular_user, DisplayOption.new).create?
  end

  test "should authorize admin to edit" do
    assert Pundit.policy(@admin_user, @display_option).edit?
  end

  test "should not authorize regular user to edit" do
    assert_not Pundit.policy(@regular_user, @display_option).edit?
  end

  test "should authorize admin to update" do
    assert Pundit.policy(@admin_user, @display_option).update?
  end

  test "should not authorize regular user to update" do
    assert_not Pundit.policy(@regular_user, @display_option).update?
  end

  test "should authorize admin to destroy" do
    assert Pundit.policy(@admin_user, @display_option).destroy?
  end

  test "should not authorize regular user to destroy" do
    assert_not Pundit.policy(@regular_user, @display_option).destroy?
  end
end
