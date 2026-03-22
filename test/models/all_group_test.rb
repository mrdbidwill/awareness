# test/models/all_group_test.rb
require "test_helper"

class AllGroupTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @all_group = all_groups(:one)
  end

  # === Validations ===

  test "should be valid with valid attributes" do
    assert @all_group.valid?
  end

  test "should require name" do
    @all_group.name = nil
    assert_not @all_group.valid?
    assert_includes @all_group.errors[:name], "Name cannot be blank."
  end

  test "should require unique name per user case-insensitively" do
    AllGroup.create!(name: "UniqueGroup", user: @user)
    duplicate = AllGroup.new(name: "uniquegroup", user: @user)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:name], "has already been taken"
  end

  test "should allow same name for different users" do
    user2 = users(:two)
    AllGroup.create!(name: "SharedName", user: @user)
    duplicate = AllGroup.new(name: "SharedName", user: user2)
    assert duplicate.valid?
  end

  test "name should not exceed 255 characters" do
    @all_group.name = "a" * 256
    assert_not @all_group.valid?
    assert_includes @all_group.errors[:name], "Name must not exceed 255 characters."
  end

  # === Associations ===

  test "should belong to user" do
    assert_respond_to @all_group, :user
    assert_instance_of User, @all_group.user
  end

  test "should require user" do
    @all_group.user = nil
    assert_not @all_group.valid?
    assert_includes @all_group.errors[:user], "must exist"
  end

  test "should have many all_group_mushrooms" do
    assert_respond_to @all_group, :all_group_mushrooms
  end

  test "should have many mushrooms through all_group_mushrooms" do
    assert_respond_to @all_group, :mushrooms
  end

  # === Dependent Associations ===

  test "should have dependent destroy configured for all_group_mushrooms" do
    # Verify dependent: :destroy is configured
    reflection = AllGroup.reflect_on_association(:all_group_mushrooms)
    assert_equal :destroy, reflection.options[:dependent], "all_group_mushrooms should have dependent: :destroy"
  end

  # === Business Logic ===

  test "can_be_deleted? should return true" do
    assert @all_group.can_be_deleted?
  end

  # === CRUD Operations ===

  test "should create new all_group" do
    assert_difference "AllGroup.count", 1 do
      AllGroup.create!(name: "New Group", user: @user)
    end
  end

  test "should update all_group attributes" do
    @all_group.update(name: "Updated Group")
    assert_equal "Updated Group", @all_group.reload.name
  end


  # === Timestamps ===

  test "should have timestamps" do
    assert_not_nil @all_group.created_at
    assert_not_nil @all_group.updated_at
  end

  # === Edge Cases ===

  test "should handle empty name" do
    @all_group.name = ""
    assert_not @all_group.valid?
  end

  test "should accept maximum length name" do
    @all_group.name = "a" * 255
    assert @all_group.valid?
  end
end
