require "test_helper"

class MushroomProjectsTest < ActiveSupport::TestCase
  def setup
    @mushroom_projects = mushroom_projects(:one)
  end

  test "should be valid with valid associations" do
    assert @mushroom_projects.valid?
  end
end