require "test_helper"

class ObservationMethodTest < ActiveSupport::TestCase
  test "should be valid with a unique name" do
    observation_method = ObservationMethod.new(name: "Valid Option")
    assert observation_method.valid?
  end

  test "should not be valid without a name" do
    observation_method = ObservationMethod.new
    assert_not observation_method.valid?
  end

  test "should enforce unique name validation" do
    observation_method1 = ObservationMethod.create!(name: "Unique Option")
    observation_method2 = ObservationMethod.new(name: "Unique Option")
    assert_not observation_method2.valid?
  end
end
