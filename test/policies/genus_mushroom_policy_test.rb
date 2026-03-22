require 'test_helper'

class GenusMushroomPolicyTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @genus_mushroom = GenusMushroom.new
  end

  test "should authorize any user to view index" do
    assert Pundit.policy(@user, GenusMushroom).index?
  end

  test "should authorize any user to show" do
    assert Pundit.policy(@user, @genus_mushroom).show?
  end

  test "should authorize any user to create" do
    assert Pundit.policy(@user, GenusMushroom.new).create?
  end

  test "should authorize any user to new" do
    assert Pundit.policy(@user, GenusMushroom.new).new?
  end

  test "should authorize any user to update" do
    assert Pundit.policy(@user, @genus_mushroom).update?
  end

  test "should authorize any user to edit" do
    assert Pundit.policy(@user, @genus_mushroom).edit?
  end

  test "should authorize any user to destroy" do
    assert Pundit.policy(@user, @genus_mushroom).destroy?
  end
end
