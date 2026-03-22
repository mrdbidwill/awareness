require "test_helper"

class MushroomPlantsTest < ActiveSupport::TestCase
  def setup
    @mushroom_plants = mushroom_plants(:one)
  end

  test "should be valid with valid associations" do
    assert @mushroom_plants.valid?
  end
end