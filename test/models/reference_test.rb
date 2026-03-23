require "test_helper"

class ReferenceTest < ActiveSupport::TestCase
  test "requires name" do
    reference = Reference.new(author: "Someone")
    assert_not reference.valid?
    assert reference.errors[:name].any?
  end

  test "accepts publish year and stores january 1 of that year" do
    reference = Reference.new(name: "Year-only reference", publish_year: "2024")

    assert reference.valid?
    assert_equal Date.new(2024, 1, 1), reference.publish_date
  end

  test "rejects non-year publish year values" do
    reference = Reference.new(name: "Invalid year reference", publish_year: "2024-03-01")

    assert_not reference.valid?
    assert_includes reference.errors[:publish_year], "must be a 4-digit year (YYYY)"
  end
end
