# test/models/mushroom_species_test.rb
require "test_helper"

class MushroomSpeciesTest < ActiveSupport::TestCase
  def setup
    @mushroom = mushrooms(:one)
    @species = species(:one)
    # Don't load from fixtures, create fresh for each test
    MushroomSpecies.where(mushroom: @mushroom, species: @species).destroy_all
    @mushroom_species = MushroomSpecies.create!(mushroom: @mushroom, species: @species)
  end

  # === Validations ===

  test "should be valid with valid attributes" do
    assert @mushroom_species.valid?
  end

  test "should require mushroom" do
    mushroom_species = MushroomSpecies.new(species: @species)
    assert_not mushroom_species.valid?
    assert_includes mushroom_species.errors[:mushroom_id], "Mushroom cannot be blank."
  end

  test "should require species" do
    mushroom_species = MushroomSpecies.new(mushroom: @mushroom)
    assert_not mushroom_species.valid?
    assert_includes mushroom_species.errors[:species_id], "Species cannot be blank."
  end

  # === Associations ===

  test "should belong to mushroom" do
    assert_respond_to @mushroom_species, :mushroom
    assert_instance_of Mushroom, @mushroom_species.mushroom
  end

  test "should belong to species" do
    assert_respond_to @mushroom_species, :species
    assert_instance_of Species, @mushroom_species.species
  end

  # === CRUD Operations ===

  test "should create mushroom_species" do
    genus = Genus.create!(name: "Another Genus")
    species2 = Species.create!(name: "Another Species", genus: genus)
    assert_difference "MushroomSpecies.count", 1 do
      MushroomSpecies.create!(mushroom: @mushroom, species: species2)
    end
  end

  test "should delete mushroom_species" do
    assert_difference "MushroomSpecies.count", -1 do
      @mushroom_species.destroy
    end
  end

  test "should have timestamps" do
    assert_not_nil @mushroom_species.created_at
    assert_not_nil @mushroom_species.updated_at
  end

  # === Business Logic ===

  test "should allow same species for different mushrooms" do
    mushroom2 = Mushroom.create!(
      name: "Another Mushroom",
      user: @mushroom.user,
      country: countries(:one),
      fungus_type: fungus_types(:one),
      collection_date: Date.today
    )
    mushroom_species2 = MushroomSpecies.new(mushroom: mushroom2, species: @species)
    assert mushroom_species2.valid?
  end

  test "should allow same mushroom with different species" do
    genus = Genus.create!(name: "Genus 2")
    species2 = Species.create!(name: "Species 2", genus: genus)
    mushroom_species2 = MushroomSpecies.new(mushroom: @mushroom, species: species2)
    assert mushroom_species2.valid?
  end
end