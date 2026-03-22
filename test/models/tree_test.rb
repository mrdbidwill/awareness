# test/models/tree_test.rb
require "test_helper"

class TreeTest < ActiveSupport::TestCase
  def setup
    @tree = trees(:one)
  end

  # === Validations ===

  test "should be valid with valid attributes" do
    assert @tree.valid?
  end

  test "should have name attribute" do
    assert_respond_to @tree, :name
  end

  # === Associations ===

  test "should have many mushroom_trees" do
    assert_respond_to @tree, :mushroom_trees
  end

  test "should have many mushrooms through mushroom_trees" do
    assert_respond_to @tree, :mushrooms
  end

  # === Dependent Associations ===

  test "should have dependent destroy configured for mushroom_trees" do
    # Verify dependent: :destroy is configured
    reflection = Tree.reflect_on_association(:mushroom_trees)
    assert_equal :destroy, reflection.options[:dependent], "mushroom_trees should have dependent: :destroy"
  end

  # === CRUD Operations ===

  test "should create new tree" do
    assert_difference "Tree.count", 1 do
      Tree.create!(name: "New Tree")
    end
  end

  test "should update tree attributes" do
    @tree.update(name: "Updated Tree")
    assert_equal "Updated Tree", @tree.reload.name
  end


  # === Timestamps ===

  test "should have timestamps" do
    assert_not_nil @tree.created_at
    assert_not_nil @tree.updated_at
  end
end