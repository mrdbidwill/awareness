# test/models/genus_mushroom_test.rb
require "test_helper"

class GenusMushroomTest < ActiveSupport::TestCase
  def setup
    @genus = genera(:one)
    @mushroom = mushrooms(:one)
    @genus_mushroom = genus_mushrooms(:one)
  end

  # === Validations ===

  test "should be valid with valid attributes" do
    assert @genus_mushroom.valid?
  end

  test "should require genus" do
    genus_mushroom = GenusMushroom.new(mushroom: @mushroom)
    assert_not genus_mushroom.valid?
    assert_includes genus_mushroom.errors[:genus], "must exist"
  end

  test "should require mushroom" do
    genus_mushroom = GenusMushroom.new(genus: @genus)
    assert_not genus_mushroom.valid?
    assert_includes genus_mushroom.errors[:mushroom], "must exist"
  end

  # === Associations ===

  test "should belong to genus" do
    assert_respond_to @genus_mushroom, :genus
    assert_instance_of Genus, @genus_mushroom.genus
  end

  test "should belong to mushroom" do
    assert_respond_to @genus_mushroom, :mushroom
    assert_instance_of Mushroom, @genus_mushroom.mushroom
  end

  # === CRUD Operations ===

  test "should create genus_mushroom" do
    genus = Genus.create!(name: "Another Genus")
    assert_difference "GenusMushroom.count", 1 do
      GenusMushroom.create!(genus: genus, mushroom: @mushroom)
    end
  end

  test "should delete genus_mushroom" do
    assert_difference "GenusMushroom.count", -1 do
      @genus_mushroom.destroy
    end
  end

  test "should have timestamps" do
    assert_not_nil @genus_mushroom.created_at
    assert_not_nil @genus_mushroom.updated_at
  end

  # === Business Logic ===

  test "should allow same genus for different mushrooms" do
    mushroom2 = Mushroom.create!(
      name: "Another Mushroom",
      user: @mushroom.user,
      country: countries(:one),
      fungus_type: fungus_types(:one),
      collection_date: Date.today
    )
    genus_mushroom2 = GenusMushroom.new(genus: @genus, mushroom: mushroom2)
    assert genus_mushroom2.valid?
  end

  test "should allow same mushroom with different genera" do
    genus2 = Genus.create!(name: "Genus 2")
    genus_mushroom2 = GenusMushroom.new(genus: genus2, mushroom: @mushroom)
    assert genus_mushroom2.valid?
  end
end
