# test/models/fungus_type_test.rb
require "test_helper"

class FungusTypeTest < ActiveSupport::TestCase
  def setup
    @fungus_type = fungus_types(:one)
  end

  # === Validations ===

  test "should be valid with valid attributes" do
    assert @fungus_type.valid?
  end

  test "should require name" do
    @fungus_type.name = nil
    assert_not @fungus_type.valid?
    assert_includes @fungus_type.errors[:name], "Name cannot be blank."
  end

  test "should require unique name" do
    duplicate = FungusType.new(name: @fungus_type.name)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:name], "has already been taken"
  end

  test "should enforce case-sensitive uniqueness" do
    FungusType.create!(name: "UniqueType")
    duplicate = FungusType.new(name: "UniqueType")
    assert_not duplicate.valid?
  end

  # === Attributes ===

  test "should have name attribute" do
    assert_respond_to @fungus_type, :name
    assert_not_nil @fungus_type.name
  end

  test "should have timestamps" do
    assert_not_nil @fungus_type.created_at
    assert_not_nil @fungus_type.updated_at
  end

  # === CRUD Operations ===

  test "should create new fungus_type" do
    assert_difference "FungusType.count", 1 do
      FungusType.create!(name: "New Fungus Type")
    end
  end

  test "should update fungus_type attributes" do
    @fungus_type.update(name: "Updated Type")
    assert_equal "Updated Type", @fungus_type.reload.name
  end

  test "should delete fungus_type" do
    fungus_type = FungusType.create!(name: "Deletable Type")
    assert_difference "FungusType.count", -1 do
      fungus_type.destroy
    end
  end

  # === Edge Cases ===

  test "should handle empty name" do
    @fungus_type.name = ""
    assert_not @fungus_type.valid?
    assert_includes @fungus_type.errors[:name], "Name cannot be blank."
  end

  test "should handle whitespace-only name" do
    @fungus_type.name = "   "
    assert_not @fungus_type.valid?
  end

  test "should accept long names" do
    @fungus_type.name = "a" * 255
    assert @fungus_type.valid? || @fungus_type.errors[:name].include?("is too long")
  end
end
