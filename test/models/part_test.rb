require "test_helper"

class PartTest < ActiveSupport::TestCase
  test "should be valid with a unique name" do
    part = Part.new(name: "Valid Option")
    assert part.valid?
  end

  test "should not be valid without a name" do
    part = Part.new
    assert_not part.valid?
  end

  test "should enforce unique name validation" do
    part1 = Part.create!(name: "Unique Option")
    part2 = Part.new(name: "Unique Option")
    assert_not part2.valid?
  end
end
