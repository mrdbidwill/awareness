# test/models/mushroom_tree_test.rb
require "test_helper"

class MushroomTreeTest < ActiveSupport::TestCase
  def setup
    @mushroom = mushrooms(:one)
    @tree = trees(:one)
    @mushroom_tree = mushroom_trees(:one)
  end

  # === Validations ===

  test "should be valid with valid attributes" do
    assert @mushroom_tree.valid?
  end

  test "should require tree" do
    mushroom_tree = MushroomTree.new(mushroom: @mushroom)
    assert_not mushroom_tree.valid?
    assert_includes mushroom_tree.errors[:tree], "must exist"
  end

  test "should require mushroom" do
    mushroom_tree = MushroomTree.new(tree: @tree)
    assert_not mushroom_tree.valid?
    assert_includes mushroom_tree.errors[:mushroom], "must exist"
  end

  test "should enforce uniqueness of tree per mushroom" do
    # Clean up any existing associations from fixtures
    MushroomTree.where(tree: @tree, mushroom: @mushroom).destroy_all
    MushroomTree.create!(tree: @tree, mushroom: @mushroom)
    duplicate = MushroomTree.new(tree: @tree, mushroom: @mushroom)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:tree_id], "is already associated with this mushroom"
  end

  # === Associations ===

  test "should belong to tree" do
    assert_respond_to @mushroom_tree, :tree
    assert_instance_of Tree, @mushroom_tree.tree
  end

  test "should belong to mushroom" do
    assert_respond_to @mushroom_tree, :mushroom
    assert_instance_of Mushroom, @mushroom_tree.mushroom
  end

  # === Counter Cache ===

  test "should increment trees_count on mushroom when created" do
    mushroom = Mushroom.create!(
      name: "Test Mushroom",
      user: users(:one),
      country: countries(:one),
      fungus_type: fungus_types(:one),
      collection_date: Date.today
    )
    initial_count = mushroom.trees_count || 0

    tree2 = Tree.create!(name: "Another Tree")
    MushroomTree.create!(mushroom: mushroom, tree: tree2)

    assert_equal initial_count + 1, mushroom.reload.trees_count
  end

  test "should decrement trees_count on mushroom when destroyed" do
    mushroom = Mushroom.create!(
      name: "Test Mushroom 2",
      user: users(:one),
      country: countries(:one),
      fungus_type: fungus_types(:one),
      collection_date: Date.today
    )
    tree2 = Tree.create!(name: "Tree for counting")
    mushroom_tree = MushroomTree.create!(mushroom: mushroom, tree: tree2)

    count_after_create = mushroom.reload.trees_count
    mushroom_tree.destroy

    assert_equal count_after_create - 1, mushroom.reload.trees_count
  end

  # === CRUD Operations ===

  test "should create mushroom_tree" do
    tree2 = Tree.create!(name: "New Tree")
    assert_difference "MushroomTree.count", 1 do
      MushroomTree.create!(tree: tree2, mushroom: @mushroom)
    end
  end

  test "should delete mushroom_tree" do
    assert_difference "MushroomTree.count", -1 do
      @mushroom_tree.destroy
    end
  end

  test "should have timestamps" do
    assert_not_nil @mushroom_tree.created_at
    assert_not_nil @mushroom_tree.updated_at
  end

  # === Business Logic ===

  test "should allow same tree for different mushrooms" do
    mushroom2 = Mushroom.create!(
      name: "Mushroom 2",
      user: users(:one),
      country: countries(:one),
      fungus_type: fungus_types(:one),
      collection_date: Date.today
    )
    mushroom_tree2 = MushroomTree.new(tree: @tree, mushroom: mushroom2)
    assert mushroom_tree2.valid?
  end

  test "should allow same mushroom with different trees" do
    tree2 = Tree.create!(name: "Tree 2")
    mushroom_tree2 = MushroomTree.new(tree: tree2, mushroom: @mushroom)
    assert mushroom_tree2.valid?
  end
end
