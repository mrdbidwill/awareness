require "test_helper"

class InaturalistObservationFieldTest < ActiveSupport::TestCase
  test "should be valid with required attributes" do
    field = InaturalistObservationField.new(
      inaturalist_id: 12345,
      name: "Test Field",
      datatype: "text",
      description: "A test observation field"
    )
    assert field.valid?
  end

  test "should require inaturalist_id" do
    field = InaturalistObservationField.new(name: "Test")
    assert_not field.valid?
    assert field.errors[:inaturalist_id].any?
  end

  test "should require name" do
    field = InaturalistObservationField.new(inaturalist_id: 123)
    assert_not field.valid?
    assert field.errors[:name].any?
  end

  test "should require unique inaturalist_id" do
    field1 = InaturalistObservationField.create!(
      inaturalist_id: 999,
      name: "First Field"
    )
    field2 = InaturalistObservationField.new(
      inaturalist_id: 999,
      name: "Second Field"
    )
    assert_not field2.valid?
    assert_includes field2.errors[:inaturalist_id], "has already been taken"
  end

  test "search scope should find by name" do
    field = InaturalistObservationField.create!(
      inaturalist_id: 1001,
      name: "Mushroom Cap Color"
    )
    results = InaturalistObservationField.search("mushroom")
    assert_includes results, field
  end

  test "search scope should find by description" do
    field = InaturalistObservationField.create!(
      inaturalist_id: 1002,
      name: "Test Field",
      description: "This field is for mushroom spore prints"
    )
    results = InaturalistObservationField.search("spore")
    assert_includes results, field
  end

  test "search scope should find by allowed_values" do
    field = InaturalistObservationField.create!(
      inaturalist_id: 1003,
      name: "Test Field",
      allowed_values: "red|white|brown|yellow"
    )
    results = InaturalistObservationField.search("brown")
    assert_includes results, field
  end

  test "search scope should return all when query is blank" do
    field1 = InaturalistObservationField.create!(inaturalist_id: 1004, name: "Field 1")
    field2 = InaturalistObservationField.create!(inaturalist_id: 1005, name: "Field 2")
    results = InaturalistObservationField.search("")
    assert_includes results, field1
    assert_includes results, field2
  end

  test "recent scope should order by created_at desc" do
    field1 = InaturalistObservationField.create!(
      inaturalist_id: 1006,
      name: "Old Field",
      created_at: 2.days.ago
    )
    field2 = InaturalistObservationField.create!(
      inaturalist_id: 1007,
      name: "New Field",
      created_at: 1.day.ago
    )
    results = InaturalistObservationField.recent
    assert_equal field2, results.first
  end

  test "by_name scope should order by name asc" do
    field1 = InaturalistObservationField.create!(inaturalist_id: 1008, name: "Zebra")
    field2 = InaturalistObservationField.create!(inaturalist_id: 1009, name: "Apple")
    results = InaturalistObservationField.by_name
    assert_equal field2, results.first
  end
end
