# test/models/mushroom_test.rb

require "test_helper"

class MushroomTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @mushroom = mushrooms(:one) # Refers to data in fixtures/mushrooms.yml
  end

  # === Validations ===

  test "should be valid with valid attributes" do
    assert @mushroom.valid?
  end

  test "should require name" do
    @mushroom.name = nil
    assert_not @mushroom.valid?
    assert_includes @mushroom.errors[:name], "Name cannot be blank."
  end

  test "should not save with a duplicate name for the same user" do
    duplicate_mushroom = @mushroom.dup
    refute duplicate_mushroom.valid?

    expected_message = I18n.t("activerecord.errors.models.mushroom.attributes.name.unique")
    assert_includes duplicate_mushroom.errors[:name], expected_message
  end

  test "should enforce unique names for the same user but allow duplicates for different users" do
    user1 = users(:one)
    user2 = users(:two)

    mushroom1 = Mushroom.create!(
      name: "Mushroom Name",
      user: user1,
      country: countries(:one),
      fungus_type: fungus_types(:one),
      collection_date: Date.today
    )

    duplicate_mushroom = Mushroom.new(
      name: "Mushroom Name",
      user: user1,
      country: countries(:one),
      fungus_type: fungus_types(:one),
      collection_date: Date.today
    )
    assert_not duplicate_mushroom.valid?, "Duplicate name for the same user should not be valid"

    mushroom_for_user2 = Mushroom.new(
      name: "Mushroom Name",
      user: user2,
      country: countries(:one),
      fungus_type: fungus_types(:one),
      collection_date: Date.today
    )
    assert mushroom_for_user2.valid?, "Mushrooms with the same name should be valid for different users"
  end

  test "name should not exceed 255 characters" do
    @mushroom.name = "a" * 256
    assert_not @mushroom.valid?, "Mushroom name should not exceed the character limit"
    assert_includes @mushroom.errors[:name], "Mushroom Name must not exceed 255 characters."
  end

  test "should require country" do
    @mushroom.country = nil
    assert_not @mushroom.valid?
    assert_includes @mushroom.errors[:country], "must exist"
  end

  test "should require fungus_type" do
    @mushroom.fungus_type = nil
    assert_not @mushroom.valid?
    assert_includes @mushroom.errors[:fungus_type], "must exist"
  end

  test "description should not exceed 4096 characters" do
    @mushroom.description = "a" * 4097
    refute @mushroom.valid?

    expected_message = I18n.t("errors.messages.too_long",
                              attribute: I18n.t("activerecord.attributes.mushroom.description"),
                              count: 4096)
    assert_includes @mushroom.errors[:description], expected_message
  end

  test "comments should not exceed 4096 characters" do
    @mushroom.comments = "a" * 4097
    assert_not @mushroom.valid?
    assert_includes @mushroom.errors[:comments], "Mushroom Comments must not exceed 4096 characters."
  end

  test "state is optional" do
    @mushroom.state = nil
    assert @mushroom.valid?, "Mushroom should be valid without state"
  end

  # Note: storage_location association removed from model

  # === Associations - belongs_to ===

  test "should belong to user" do
    assert_respond_to @mushroom, :user
    assert_instance_of User, @mushroom.user
  end

  test "should not be valid without a user" do
    @mushroom.user = nil
    assert_not @mushroom.valid?
    assert_includes @mushroom.errors[:user], "must exist"
  end

  test "should belong to country" do
    assert_respond_to @mushroom, :country
    assert_instance_of Country, @mushroom.country
  end

  test "should belong to state optionally" do
    assert_respond_to @mushroom, :state
  end

  test "should belong to fungus_type" do
    assert_respond_to @mushroom, :fungus_type
    assert_instance_of FungusType, @mushroom.fungus_type
  end

  test "should belong to mushroom_storage_location optionally" do
    assert_respond_to @mushroom, :mushroom_storage_location
  end

  # === Associations - has_many ===

  test "should have many all_group_mushrooms" do
    assert_respond_to @mushroom, :all_group_mushrooms
  end

  test "should have many all_groups through all_group_mushrooms" do
    assert_respond_to @mushroom, :all_groups
  end

  test "should have many cluster_mushrooms" do
    assert_respond_to @mushroom, :cluster_mushrooms
    assert_instance_of ClusterMushroom, @mushroom.cluster_mushrooms.first if @mushroom.cluster_mushrooms.any?
  end

  test "should have many clusters through cluster_mushrooms" do
    assert_respond_to @mushroom, :clusters
  end

  test "should have many genus_mushrooms" do
    assert_respond_to @mushroom, :genus_mushrooms
  end

  test "should have many genera through genus_mushrooms" do
    assert_respond_to @mushroom, :genera
  end

  test "should have many mushroom_species" do
    assert_respond_to @mushroom, :mushroom_species
  end

  test "should have many species through mushroom_species" do
    assert_respond_to @mushroom, :species
  end

  test "should have many mushroom_trees" do
    assert_respond_to @mushroom, :mushroom_trees
  end

  test "should have many trees through mushroom_trees" do
    assert_respond_to @mushroom, :trees
  end

  test "should have many mushroom_plants" do
    assert_respond_to @mushroom, :mushroom_plants
  end

  test "should have many plants through mushroom_plants" do
    assert_respond_to @mushroom, :plants
  end

  test "should have many mushroom_projects" do
    assert_respond_to @mushroom, :mushroom_projects
  end

  test "should have many projects through mushroom_projects" do
    assert_respond_to @mushroom, :projects
  end

  test "should have many mr_character_mushrooms" do
    assert_respond_to @mushroom, :mr_character_mushrooms
  end

  test "should have many mr_characters through mr_character_mushrooms" do
    assert_respond_to @mushroom, :mr_characters
    assert @mushroom.mr_characters.count > 0, "Expected at least 1 associated mr_character"
  end

  test "should have many image_mushrooms" do
    assert_respond_to @mushroom, :image_mushrooms
  end

  test "should have many images through image_mushrooms" do
    assert_respond_to @mushroom, :images
  end

  # === Dependent Destroys ===

  test "should destroy associated all_group_mushrooms" do
    all_group = @mushroom.user.all_groups.create!(name: "Test Group")
    @mushroom.all_group_mushrooms.create!(all_group: all_group)

    initial_count = @mushroom.all_group_mushrooms.count
    assert_difference "AllGroupMushroom.count", -initial_count do
      @mushroom.destroy
    end
  end

  test "should destroy associated cluster_mushrooms" do
    initial_count = @mushroom.cluster_mushrooms.count
    assert_difference "ClusterMushroom.count", -initial_count do
      @mushroom.destroy
    end
  end

  test "should destroy associated genus_mushrooms" do
    assert_difference "GenusMushroom.count", -@mushroom.genus_mushrooms.count do
      @mushroom.destroy
    end
  end

  test "should destroy associated mushroom_species" do
    assert_difference "MushroomSpecies.count", -@mushroom.mushroom_species.count do
      @mushroom.destroy
    end
  end

  test "should destroy associated mushroom_trees" do
    assert_difference "MushroomTree.count", -@mushroom.mushroom_trees.count do
      @mushroom.destroy
    end
  end

  test "should destroy associated mushroom_plants" do
    assert_difference "MushroomPlant.count", -@mushroom.mushroom_plants.count do
      @mushroom.destroy
    end
  end

  test "should destroy associated mushroom_projects" do
    assert_difference "MushroomProject.count", -@mushroom.mushroom_projects.count do
      @mushroom.destroy
    end
  end

  test "should destroy associated mr_character_mushrooms" do
    assert_difference "MrCharacterMushroom.count", -@mushroom.mr_character_mushrooms.count do
      @mushroom.destroy
    end
  end

  test "should destroy associated image_mushrooms" do
    assert_difference "ImageMushroom.count", -@mushroom.image_mushrooms.count do
      @mushroom.destroy
    end
  end

  # === Callbacks ===

  test "should prevent id change" do
    original_id = @mushroom.id
    assert_raises(ActiveRecord::ReadonlyAttributeError) do
      @mushroom.id = original_id + 1
    end
  end

  test "id should be readonly" do
    assert @mushroom.class.readonly_attributes.include?("id")
  end

  # === CRUD Operations ===

  test "should create mushroom with valid attributes" do
    assert_difference "Mushroom.count", 1 do
      Mushroom.create!(
        name: "New Mushroom",
        user: @user,
        country: countries(:one),
        fungus_type: fungus_types(:one),
        collection_date: Date.today
      )
    end
  end

  test "should update mushroom attributes" do
    @mushroom.update(name: "Updated Name")
    assert_equal "Updated Name", @mushroom.reload.name
  end

  test "should destroy mushroom" do
    assert_difference "Mushroom.count", -1 do
      @mushroom.destroy
    end
  end

  # === Timestamps ===

  test "should have timestamps" do
    assert_not_nil @mushroom.created_at
    assert_not_nil @mushroom.updated_at
  end

  test "should update updated_at on save" do
    original_time = @mushroom.updated_at
    sleep 0.01 # Ensure time difference
    @mushroom.update(name: "Updated")
    assert @mushroom.updated_at > original_time
  end

  # === Edge Cases ===

  test "should handle nil description" do
    @mushroom.description = nil
    assert @mushroom.valid?
  end

  test "should handle nil comments" do
    @mushroom.comments = nil
    assert @mushroom.valid?
  end

  test "should handle empty string for optional fields" do
    @mushroom.description = ""
    @mushroom.comments = ""
    assert @mushroom.valid?
  end

  test "should accept maximum length strings" do
    @mushroom.name = "a" * 255
    @mushroom.description = "b" * 4096
    @mushroom.comments = "c" * 4096
    assert @mushroom.valid?
  end

  # === Collection Date ===

  test "collection_date is optional" do
    @mushroom.collection_date = nil
    assert @mushroom.valid?, "Mushroom should be valid without collection_date"
  end

  test "should accept valid past collection_date" do
    @mushroom.collection_date = 30.days.ago.to_date
    assert @mushroom.valid?
    assert_equal 30.days.ago.to_date, @mushroom.collection_date
  end

  test "should accept today as collection_date" do
    @mushroom.collection_date = Date.today
    assert @mushroom.valid?
    assert_equal Date.today, @mushroom.collection_date
  end

  test "should handle blank collection_date" do
    @mushroom.collection_date = ""
    assert @mushroom.valid?
  end

  test "should associate with different countries" do
    country2 = countries(:two)
    @mushroom.country = country2
    assert @mushroom.valid?
    assert_equal country2, @mushroom.country
  end

  test "should associate with different fungus types" do
    fungus_type2 = fungus_types(:two)
    @mushroom.fungus_type = fungus_type2
    assert @mushroom.valid?
    assert_equal fungus_type2, @mushroom.fungus_type
  end
end
