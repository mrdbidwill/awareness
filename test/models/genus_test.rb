# test/models/genus_test.rb
require "test_helper"

class GenusTest < ActiveSupport::TestCase
  def setup
    @genus = genera(:one)
  end

  # === Validations ===

  test "should be valid with valid attributes" do
    assert @genus.valid?
  end

  test "should have name attribute" do
    assert_respond_to @genus, :name
  end

  # === Associations ===

  test "should have many genus_mushrooms" do
    assert_respond_to @genus, :genus_mushrooms
  end

  test "should have many mushrooms through genus_mushrooms" do
    assert_respond_to @genus, :mushrooms
    assert_instance_of Mushroom, @genus.mushrooms.first if @genus.mushrooms.any?
  end

  test "should have many species" do
    assert_respond_to @genus, :species
  end

  # === Dependent Associations ===

  test "should have dependent destroy configured for genus_mushrooms" do
    # Verify dependent: :destroy is configured
    reflection = Genus.reflect_on_association(:genus_mushrooms)
    assert_equal :destroy, reflection.options[:dependent], "genus_mushrooms should have dependent: :destroy"
  end

  test "should have dependent destroy configured for species" do
    # Verify dependent: :destroy is configured
    reflection = Genus.reflect_on_association(:species)
    assert_equal :destroy, reflection.options[:dependent], "species should have dependent: :destroy"
  end

  # === CRUD Operations ===

  test "should create new genus" do
    assert_difference "Genus.count", 1 do
      Genus.create!(name: "New Genus")
    end
  end

  test "should update genus attributes" do
    @genus.update(name: "Updated Genus")
    assert_equal "Updated Genus", @genus.reload.name
  end


  # === Timestamps ===

  test "should have timestamps" do
    assert_not_nil @genus.created_at
    assert_not_nil @genus.updated_at
  end

  # === Table Name ===

  test "should use genera table name" do
    assert_equal "genera", Genus.table_name
  end
end