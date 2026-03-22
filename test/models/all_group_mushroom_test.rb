# test/models/all_group_mushroom_test.rb
require "test_helper"

class AllGroupMushroomTest < ActiveSupport::TestCase
  def setup
    @mushroom = mushrooms(:one)
    @all_group = all_groups(:one)
    @all_group_mushroom = all_group_mushrooms(:one)
  end

  # === Validations ===

  test "should be valid with valid attributes" do
    assert @all_group_mushroom.valid?
  end

  test "should require mushroom" do
    all_group_mushroom = AllGroupMushroom.new(all_group: @all_group)
    assert_not all_group_mushroom.valid?
    assert_includes all_group_mushroom.errors[:mushroom], "must exist"
  end

  test "should require all_group" do
    all_group_mushroom = AllGroupMushroom.new(mushroom: @mushroom)
    assert_not all_group_mushroom.valid?
    assert_includes all_group_mushroom.errors[:all_group], "must exist"
  end

  test "should enforce same user for mushroom and all_group" do
    user2 = users(:two)
    other_group = AllGroup.create!(name: "Other Group", user: user2)
    all_group_mushroom = AllGroupMushroom.new(mushroom: @mushroom, all_group: other_group)
    assert_not all_group_mushroom.valid?
    assert_includes all_group_mushroom.errors[:all_group], "must belong to the same user as the mushroom"
  end

  test "should enforce uniqueness of all_group per mushroom" do
    # all_group_mushrooms(:one) already exists with mushroom:one + all_group:one
    # Try to create a duplicate
    duplicate = AllGroupMushroom.new(mushroom: @mushroom, all_group: @all_group)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:base], "This group is already attached to this mushroom"
  end

  # === Associations ===

  test "should belong to mushroom" do
    assert_respond_to @all_group_mushroom, :mushroom
    assert_instance_of Mushroom, @all_group_mushroom.mushroom
  end

  test "should belong to all_group" do
    assert_respond_to @all_group_mushroom, :all_group
    assert_instance_of AllGroup, @all_group_mushroom.all_group
  end

  # === CRUD Operations ===

  test "should create all_group_mushroom" do
    group2 = AllGroup.create!(name: "Another Group", user: @mushroom.user)
    assert_difference "AllGroupMushroom.count", 1 do
      AllGroupMushroom.create!(mushroom: @mushroom, all_group: group2)
    end
  end

  test "should delete all_group_mushroom" do
    assert_difference "AllGroupMushroom.count", -1 do
      @all_group_mushroom.destroy
    end
  end

  test "should have timestamps" do
    assert_not_nil @all_group_mushroom.created_at
    assert_not_nil @all_group_mushroom.updated_at
  end

  # === Business Logic ===

  test "should allow same all_group for different mushrooms" do
    mushroom2 = Mushroom.create!(
      name: "Another Mushroom",
      user: @mushroom.user,
      country: countries(:one),
      fungus_type: fungus_types(:one),
      collection_date: Date.today
    )
    all_group_mushroom2 = AllGroupMushroom.new(mushroom: mushroom2, all_group: @all_group)
    assert all_group_mushroom2.valid?
  end

  test "should allow same mushroom with different all_groups" do
    group2 = AllGroup.create!(name: "Group 2", user: @mushroom.user)
    all_group_mushroom2 = AllGroupMushroom.new(mushroom: @mushroom, all_group: group2)
    assert all_group_mushroom2.valid?
  end
end
