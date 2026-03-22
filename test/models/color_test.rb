# test/models/color_test.rb
require "test_helper"

class ColorTest < ActiveSupport::TestCase
  def setup
    @color = colors(:one)
  end

  test "should be valid with valid attributes" do
    assert @color.valid?
  end

  test "should require latin_name" do
    color = Color.new(common_name: "Test Color")
    assert_not color.valid?
    assert_includes color.errors[:latin_name], "Latin name cannot be blank."
  end

  test "should require common_name" do
    color = Color.new(latin_name: "Test Latin")
    assert_not color.valid?
    assert_includes color.errors[:common_name], "Common name cannot be blank."
  end

  test "should have by_sequence scope" do
    assert_respond_to Color, :by_sequence
  end

  test "should have by_group scope" do
    assert_respond_to Color, :by_group
  end

  test "should have timestamps" do
    assert_not_nil @color.created_at
    assert_not_nil @color.updated_at
  end
end
