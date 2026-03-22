require 'test_helper'

class FungusTypePolicyTest < ActiveSupport::TestCase
  setup do
    @admin_user = users(:one)
    @regular_user = users(:two)
    @fungus_type = FungusType.new(name: "Test Type")
  end

  test "should authorize any user to view index" do
    assert Pundit.policy(@regular_user, FungusType).index?
    assert Pundit.policy(@admin_user, FungusType).index?
  end

  test "should authorize any user to show" do
    assert Pundit.policy(@regular_user, @fungus_type).show?
    assert Pundit.policy(@admin_user, @fungus_type).show?
  end

  test "should authorize admin to new" do
    assert Pundit.policy(@admin_user, FungusType.new).new?
  end

  test "should not authorize regular user to new" do
    assert_not Pundit.policy(@regular_user, FungusType.new).new?
  end

  test "should authorize admin to create" do
    assert Pundit.policy(@admin_user, FungusType.new).create?
  end

  test "should not authorize regular user to create" do
    assert_not Pundit.policy(@regular_user, FungusType.new).create?
  end

  test "should authorize admin to edit" do
    assert Pundit.policy(@admin_user, @fungus_type).edit?
  end

  test "should not authorize regular user to edit" do
    assert_not Pundit.policy(@regular_user, @fungus_type).edit?
  end

  test "should authorize admin to update" do
    assert Pundit.policy(@admin_user, @fungus_type).update?
  end

  test "should not authorize regular user to update" do
    assert_not Pundit.policy(@regular_user, @fungus_type).update?
  end

  test "should authorize admin to destroy" do
    assert Pundit.policy(@admin_user, @fungus_type).destroy?
  end

  test "should not authorize regular user to destroy" do
    assert_not Pundit.policy(@regular_user, @fungus_type).destroy?
  end
end
