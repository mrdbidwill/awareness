# test/models/species_test.rb
require "test_helper"

class SpeciesTest < ActiveSupport::TestCase
  def setup
    @genus = genera(:one)
    @species = species(:one)
  end

  # === Validations ===

  test "should be valid with valid attributes" do
    assert @species.valid?
  end

  test "should have name attribute" do
    assert_respond_to @species, :name
  end

  # === Associations ===

  test "should belong to genus" do
    assert_respond_to @species, :genus
    assert_instance_of Genus, @species.genus if @species.genus.present?
  end

  test "should require genus" do
    @species.genus = nil
    assert_not @species.valid?
    assert_includes @species.errors[:genus], "must exist"
  end

  test "should have many mushroom_species" do
    assert_respond_to @species, :mushroom_species
  end

  test "should have many mushrooms through mushroom_species" do
    assert_respond_to @species, :mushrooms
  end

  # === Dependent Associations ===

  test "should have dependent destroy configured for mushroom_species" do
    # Verify dependent: :destroy is configured
    reflection = Species.reflect_on_association(:mushroom_species)
    assert_equal :destroy, reflection.options[:dependent], "mushroom_species should have dependent: :destroy"
  end

  # === CRUD Operations ===

  test "should create new species" do
    assert_difference "Species.count", 1 do
      Species.create!(name: "New Species", genus: @genus)
    end
  end

  test "should update species attributes" do
    @species.update(name: "Updated Species")
    assert_equal "Updated Species", @species.reload.name
  end


  # === Timestamps ===

  test "should have timestamps" do
    assert_not_nil @species.created_at
    assert_not_nil @species.updated_at
  end

  # === Foreign Key ===

  test "should use genera_id as foreign key for genus" do
    assert_equal @genus.id, @species.genera_id if @species.genus.present?
  end
end
