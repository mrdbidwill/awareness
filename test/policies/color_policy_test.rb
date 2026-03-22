require 'test_helper'

class ColorPolicyTest < ActiveSupport::TestCase
  setup do
    @admin_user = users(:one)
    @regular_user = users(:two)
    @color = Color.new(latin_name: "Rubeus", common_name: "Red")
  end

  test "should authorize admin to view index" do
    assert Pundit.policy(@admin_user, Color).index?
  end

  test "should not authorize regular user to view index" do
    assert_not Pundit.policy(@regular_user, Color).index?
  end

  test "should not authorize nil user to view index" do
    assert_not Pundit.policy(nil, Color).index?
  end

  test "should authorize admin to show" do
    assert Pundit.policy(@admin_user, @color).show?
  end

  test "should not authorize regular user to show" do
    assert_not Pundit.policy(@regular_user, @color).show?
  end

  test "should authorize admin to new" do
    assert Pundit.policy(@admin_user, Color.new).new?
  end

  test "should not authorize regular user to new" do
    assert_not Pundit.policy(@regular_user, Color.new).new?
  end

  test "should authorize admin to create" do
    assert Pundit.policy(@admin_user, Color.new).create?
  end

  test "should not authorize regular user to create" do
    assert_not Pundit.policy(@regular_user, Color.new).create?
  end

  test "should authorize admin to edit" do
    assert Pundit.policy(@admin_user, @color).edit?
  end

  test "should not authorize regular user to edit" do
    assert_not Pundit.policy(@regular_user, @color).edit?
  end

  test "should authorize admin to update" do
    assert Pundit.policy(@admin_user, @color).update?
  end

  test "should not authorize regular user to update" do
    assert_not Pundit.policy(@regular_user, @color).update?
  end

  test "should authorize admin to destroy" do
    assert Pundit.policy(@admin_user, @color).destroy?
  end

  test "should not authorize regular user to destroy" do
    assert_not Pundit.policy(@regular_user, @color).destroy?
  end
end
