require 'test_helper'

class LensPolicyTest < ActiveSupport::TestCase
  setup do
    @admin_user = users(:one)
    @regular_user = users(:two)
    @lens = Lens.new(make: "Canon", model: "50mm f/1.8")
  end

  test "should authorize admin to view index" do
    assert Pundit.policy(@admin_user, Lens).index?
  end

  test "should not authorize regular user to view index" do
    assert_not Pundit.policy(@regular_user, Lens).index?
  end

  test "should not authorize nil user to view index" do
    assert_not Pundit.policy(nil, Lens).index?
  end

  test "should authorize admin to show" do
    assert Pundit.policy(@admin_user, @lens).show?
  end

  test "should not authorize regular user to show" do
    assert_not Pundit.policy(@regular_user, @lens).show?
  end

  test "should authorize admin to new" do
    assert Pundit.policy(@admin_user, Lens.new).new?
  end

  test "should not authorize regular user to new" do
    assert_not Pundit.policy(@regular_user, Lens.new).new?
  end

  test "should authorize admin to create" do
    assert Pundit.policy(@admin_user, Lens.new).create?
  end

  test "should not authorize regular user to create" do
    assert_not Pundit.policy(@regular_user, Lens.new).create?
  end

  test "should authorize admin to edit" do
    assert Pundit.policy(@admin_user, @lens).edit?
  end

  test "should not authorize regular user to edit" do
    assert_not Pundit.policy(@regular_user, @lens).edit?
  end

  test "should authorize admin to update" do
    assert Pundit.policy(@admin_user, @lens).update?
  end

  test "should not authorize regular user to update" do
    assert_not Pundit.policy(@regular_user, @lens).update?
  end

  test "should authorize admin to destroy" do
    assert Pundit.policy(@admin_user, @lens).destroy?
  end

  test "should not authorize regular user to destroy" do
    assert_not Pundit.policy(@regular_user, @lens).destroy?
  end
end
