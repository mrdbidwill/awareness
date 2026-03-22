# test/models/lens_test.rb
require "test_helper"

class LensTest < ActiveSupport::TestCase
  def setup
    @lens = lenses(:one)
  end

  test "should be valid with valid attributes" do
    assert @lens.valid?
  end

  test "should require make" do
    lens = Lens.new(model: "Test Model")
    assert_not lens.valid?
    assert_includes lens.errors[:make], "Make cannot be blank."
  end

  test "should require model" do
    lens = Lens.new(make: "Test Make")
    assert_not lens.valid?
    assert_includes lens.errors[:model], "Model cannot be blank."
  end

  test "should have timestamps" do
    assert_not_nil @lens.created_at
    assert_not_nil @lens.updated_at
  end
end
