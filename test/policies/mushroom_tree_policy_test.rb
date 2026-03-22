require 'test_helper'

class MushroomTreePolicyTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @mushroom_tree = MushroomTree.new
  end

  test "should authorize any user to view index" do
    assert Pundit.policy(@user, MushroomTree).index?
  end

  test "should authorize any user to show" do
    assert Pundit.policy(@user, @mushroom_tree).show?
  end

  test "should authorize any user to create" do
    assert Pundit.policy(@user, MushroomTree.new).create?
  end

  test "should authorize any user to new" do
    assert Pundit.policy(@user, MushroomTree.new).new?
  end

  test "should authorize any user to update" do
    assert Pundit.policy(@user, @mushroom_tree).update?
  end

  test "should authorize any user to edit" do
    assert Pundit.policy(@user, @mushroom_tree).edit?
  end

  test "should authorize any user to destroy" do
    assert Pundit.policy(@user, @mushroom_tree).destroy?
  end
end
