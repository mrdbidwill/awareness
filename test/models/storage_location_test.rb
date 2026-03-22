# test/models/storage_location_test.rb
require "test_helper"

class StorageLocationTest < ActiveSupport::TestCase
  def setup
    @storage_location = StorageLocation.create!(name: "Test Location")
  end

  # === Validations ===

  test "should be valid with valid attributes" do
    assert @storage_location.valid?
  end

  test "should require name" do
    storage_location = StorageLocation.new(name: nil)
    assert_not storage_location.valid?
    assert_includes storage_location.errors[:name], "Name cannot be blank."
  end

  # === Associations ===

  test "should have many mushrooms" do
    assert_respond_to @storage_location, :mushrooms
  end

  # === Attributes ===

  test "should have name attribute" do
    assert_respond_to @storage_location, :name
    assert_not_nil @storage_location.name
  end

  test "should have timestamps" do
    assert_not_nil @storage_location.created_at
    assert_not_nil @storage_location.updated_at
  end

  # === CRUD Operations ===

  test "should create new storage_location" do
    assert_difference "StorageLocation.count", 1 do
      StorageLocation.create!(name: "New Location")
    end
  end

  test "should update storage_location attributes" do
    @storage_location.update(name: "Updated Location")
    assert_equal "Updated Location", @storage_location.reload.name
  end

  test "should delete storage_location" do
    location = StorageLocation.create!(name: "Deletable Location")
    assert_difference "StorageLocation.count", -1 do
      location.destroy
    end
  end

  # === Edge Cases ===

  test "should handle empty name" do
    @storage_location.name = ""
    assert_not @storage_location.valid?
  end
end
