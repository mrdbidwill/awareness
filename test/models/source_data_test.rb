require "test_helper"

class SourceDataTest < ActiveSupport::TestCase
  def setup
    # Create a valid source_data_type for testing
    @source_data_type = SourceDataType.create!(name: "Valid Type")
  end

  test "should be valid with a unique title and source_data_type" do
    source_data = SourceData.new(title: "Valid Option", source_data_type: @source_data_type)
    assert source_data.valid?
  end

  test "should not be valid without a title" do
    source_data = SourceData.new(source_data_type: @source_data_type)
    assert_not source_data.valid?
  end

  test "should not be valid without a source_data_type" do
    source_data = SourceData.new(title: "Valid Option")
    assert_not source_data.valid?
  end

  test "should enforce unique title validation" do
    SourceData.create!(title: "Unique Option", source_data_type: @source_data_type)
    duplicate = SourceData.new(title: "Unique Option", source_data_type: @source_data_type)
    assert_not duplicate.valid?
  end
end
