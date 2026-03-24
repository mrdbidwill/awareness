require "test_helper"

class SourceTest < ActiveSupport::TestCase
  test "requires name" do
    source = Source.new(author: "Someone")
    assert_not source.valid?
    assert source.errors[:name].any?
  end

  test "accepts publish year and stores january 1 of that year" do
    source = Source.new(name: "Year-only source", publish_year: "2024")

    assert source.valid?
    assert_equal Date.new(2024, 1, 1), source.publish_date
  end

  test "rejects non-year publish year values" do
    source = Source.new(name: "Invalid year source", publish_year: "2024-03-01")

    assert_not source.valid?
    assert_includes source.errors[:publish_year], "must be a 4-digit year (YYYY)"
  end
end
