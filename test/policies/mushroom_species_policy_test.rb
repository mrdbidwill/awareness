require 'test_helper'

class MushroomSpeciesPolicyTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @mushroom_species = MushroomSpecies.new
  end

  test "should authorize any user to view index" do
    assert Pundit.policy(@user, MushroomSpecies).index?
  end

  test "should authorize any user to show" do
    assert Pundit.policy(@user, @mushroom_species).show?
  end

  test "should authorize any user to create" do
    assert Pundit.policy(@user, MushroomSpecies.new).create?
  end

  test "should authorize any user to new" do
    assert Pundit.policy(@user, MushroomSpecies.new).new?
  end

  test "should authorize any user to update" do
    assert Pundit.policy(@user, @mushroom_species).update?
  end

  test "should authorize any user to edit" do
    assert Pundit.policy(@user, @mushroom_species).edit?
  end

  test "should authorize any user to destroy" do
    assert Pundit.policy(@user, @mushroom_species).destroy?
  end
end
