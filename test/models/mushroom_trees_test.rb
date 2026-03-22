require "test_helper"

class MushroomTreesTest < ActiveSupport::TestCase
  def setup
    @mushroom_tree = mushroom_trees(:one)
  end

  test "should be valid with valid mushroom and tree" do
    assert @mushroom_tree.valid?
  end
end