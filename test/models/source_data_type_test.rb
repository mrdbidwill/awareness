
require "test_helper"

class SourceDataTypeTest < ActiveSupport::TestCase
  test "should be valid with a unique name" do
    source_data_type = SourceDataType.new(name: "Valid Option")
    assert source_data_type.valid?
  end

  test "should not be valid without a name" do
    source_data_type = SourceDataType.new
    assert_not source_data_type.valid?
  end

  test "should enforce unique name validation" do
    source_data_type1 = SourceDataType.create!(name: "Unique Option")
    source_data_type2 = SourceDataType.new(name: "Unique Option")
    assert_not source_data_type2.valid?
  end
end
