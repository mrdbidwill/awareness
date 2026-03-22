require "test_helper"

class DisplayOptionTest < ActiveSupport::TestCase
  test "should be valid with a unique name" do
    display_option = DisplayOption.new(name: "Valid Option")
    assert display_option.valid?
  end

  test "should not be valid without a name" do
    display_option = DisplayOption.new(name: nil)
    assert_not display_option.valid?
  end

  test "should enforce unique name validation" do
    display_option1 = DisplayOption.create!(name: "Unique Option")
    display_option2 = DisplayOption.new(name: "Unique Option")
    assert_not display_option2.valid?
  end
end