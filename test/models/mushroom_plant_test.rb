# test/models/mushroom_plant_test.rb
require "test_helper"

class MushroomPlantTest < ActiveSupport::TestCase
  def setup
    @mushroom = mushrooms(:one)
    @plant = plants(:one)
    @mushroom_plant = mushroom_plants(:one)
  end

  # === Validations ===

  test "should be valid with valid attributes" do
    assert @mushroom_plant.valid?
  end

  test "should require plant" do
    mushroom_plant = MushroomPlant.new(mushroom: @mushroom)
    assert_not mushroom_plant.valid?
    assert_includes mushroom_plant.errors[:plant], "must exist"
  end

  test "should require mushroom" do
    mushroom_plant = MushroomPlant.new(plant: @plant)
    assert_not mushroom_plant.valid?
    assert_includes mushroom_plant.errors[:mushroom], "must exist"
  end

  test "should enforce uniqueness of plant per mushroom" do
    # mushroom_plants(:one) already exists with mushroom:one + plant:one
    # Try to create a duplicate
    duplicate = MushroomPlant.new(plant: @plant, mushroom: @mushroom)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:plant_id], "is already associated with this mushroom"
  end

  # === Associations ===

  test "should belong to plant" do
    assert_respond_to @mushroom_plant, :plant
    assert_instance_of Plant, @mushroom_plant.plant
  end

  test "should belong to mushroom" do
    assert_respond_to @mushroom_plant, :mushroom
    assert_instance_of Mushroom, @mushroom_plant.mushroom
  end

  # === Counter Cache ===

  test "should increment plants_count on mushroom when created" do
    mushroom = Mushroom.create!(
      name: "Test Mushroom",
      user: users(:one),
      country: countries(:one),
      fungus_type: fungus_types(:one),
      collection_date: Date.today
    )
    initial_count = mushroom.plants_count || 0

    plant2 = Plant.create!(name: "Another Plant")
    MushroomPlant.create!(mushroom: mushroom, plant: plant2)

    assert_equal initial_count + 1, mushroom.reload.plants_count
  end

  test "should decrement plants_count on mushroom when destroyed" do
    mushroom = Mushroom.create!(
      name: "Test Mushroom 2",
      user: users(:one),
      country: countries(:one),
      fungus_type: fungus_types(:one),
      collection_date: Date.today
    )
    plant2 = Plant.create!(name: "Plant for counting")
    mushroom_plant = MushroomPlant.create!(mushroom: mushroom, plant: plant2)

    count_after_create = mushroom.reload.plants_count
    mushroom_plant.destroy

    assert_equal count_after_create - 1, mushroom.reload.plants_count
  end

  # === CRUD Operations ===

  test "should create mushroom_plant" do
    plant2 = Plant.create!(name: "New Plant")
    assert_difference "MushroomPlant.count", 1 do
      MushroomPlant.create!(plant: plant2, mushroom: @mushroom)
    end
  end

  test "should delete mushroom_plant" do
    assert_difference "MushroomPlant.count", -1 do
      @mushroom_plant.destroy
    end
  end

  test "should have timestamps" do
    assert_not_nil @mushroom_plant.created_at
    assert_not_nil @mushroom_plant.updated_at
  end

  # === Business Logic ===

  test "should allow same plant for different mushrooms" do
    mushroom2 = Mushroom.create!(
      name: "Mushroom 2",
      user: users(:one),
      country: countries(:one),
      fungus_type: fungus_types(:one),
      collection_date: Date.today
    )
    mushroom_plant2 = MushroomPlant.new(plant: @plant, mushroom: mushroom2)
    assert mushroom_plant2.valid?
  end

  test "should allow same mushroom with different plants" do
    plant2 = Plant.create!(name: "Plant 2")
    mushroom_plant2 = MushroomPlant.new(plant: plant2, mushroom: @mushroom)
    assert mushroom_plant2.valid?
  end
end
