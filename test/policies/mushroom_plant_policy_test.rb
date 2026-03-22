require 'test_helper'

class MushroomPlantPolicyTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @mushroom_plant = MushroomPlant.new
  end

  test "should authorize any user to view index" do
    assert Pundit.policy(@user, MushroomPlant).index?
  end

  test "should authorize any user to show" do
    assert Pundit.policy(@user, @mushroom_plant).show?
  end

  test "should authorize any user to create" do
    assert Pundit.policy(@user, MushroomPlant.new).create?
  end

  test "should authorize any user to new" do
    assert Pundit.policy(@user, MushroomPlant.new).new?
  end

  test "should authorize any user to update" do
    assert Pundit.policy(@user, @mushroom_plant).update?
  end

  test "should authorize any user to edit" do
    assert Pundit.policy(@user, @mushroom_plant).edit?
  end

  test "should authorize any user to destroy" do
    assert Pundit.policy(@user, @mushroom_plant).destroy?
  end
end
