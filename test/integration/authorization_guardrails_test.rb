require "test_helper"

class AuthorizationGuardrailsTest < ActionDispatch::IntegrationTest
  GUARDED_MUTATION_CONTROLLERS = %w[
    MushroomsController
    ImageMushroomsController
    MrCharacterMushroomsController
    GenusMushroomsController
    MushroomSpeciesController
    MushroomTreesController
    MushroomPlantsController
    ClusterMushroomsController
    AllGroupMushroomsController
    MushroomProjectsController
  ].freeze

  GUARDED_MUTATION_CONTROLLER_EXCEPTIONS = {
    "MushroomComparisonsController" => "Mutation is allowed for any signed-in user; ownership is not required."
  }.freeze

  setup do
    @owner = users(:one) # Elevated Admin (permission_id 1)
    @user = users(:two)  # Regular user

    @owner_mushroom = mushrooms(:one)
    @user_mushroom = mushrooms(:two)

    @mr_character = mr_characters(:one)
    @genus = genera(:one)
    @species = species(:one)
    @tree = trees(:one)
    @plant = plants(:one)

    @user_cluster = Cluster.create!(name: "User Cluster", user: @user)
    @user_group = AllGroup.create!(name: "User Group", user: @user)
    @user_project = Project.create!(name: "User Project", user: @user)
  end

  test "non-admin cannot update another user's mushroom" do
    sign_in @user

    assert_no_changes -> { @owner_mushroom.reload.name } do
      patch mushroom_path(@owner_mushroom), params: {
        mushroom: {
          name: "Unauthorized Update"
        }
      }
    end

    assert_response :redirect
  end

  test "non-admin cannot delete another user's mushroom" do
    sign_in @user

    assert_no_difference("Mushroom.count") do
      delete mushroom_path(@owner_mushroom)
    end

    assert_response :redirect
  end

  test "non-admin cannot add character to another user's mushroom" do
    sign_in @user

    assert_no_difference("MrCharacterMushroom.count") do
      post mr_character_mushrooms_path, params: {
        mushroom_id: @owner_mushroom.id,
        mr_character_id: @mr_character.id,
        character_value: "test"
      }
    end

    assert_response :redirect
  end

  test "non-admin cannot add cluster to another user's mushroom" do
    sign_in @user

    assert_no_difference("ClusterMushroom.count") do
      post cluster_mushrooms_path, params: {
        cluster_mushroom: {
          mushroom_id: @owner_mushroom.id,
          cluster_id: @user_cluster.id
        }
      }
    end

    assert_response :redirect
  end

  test "non-admin cannot add group to another user's mushroom" do
    sign_in @user

    assert_no_difference("AllGroupMushroom.count") do
      post all_group_mushrooms_path, params: {
        all_group_mushroom: {
          mushroom_id: @owner_mushroom.id,
          all_group_id: @user_group.id
        }
      }
    end

    assert_response :redirect
  end

  test "non-admin cannot add project to another user's mushroom" do
    sign_in @user

    assert_no_difference("MushroomProject.count") do
      post mushroom_projects_path, params: {
        mushroom_project: {
          mushroom_id: @owner_mushroom.id,
          project_id: @user_project.id
        }
      }
    end

    assert_response :redirect
  end

  test "non-admin cannot attach genus to another user's mushroom" do
    sign_in @user

    assert_no_difference("GenusMushroom.count") do
      post genus_mushrooms_path(format: :json), params: {
        genus_mushroom: {
          mushroom_id: @owner_mushroom.id,
          genus_id: @genus.id
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "non-admin cannot attach species to another user's mushroom" do
    sign_in @user

    assert_no_difference("MushroomSpecies.count") do
      post mushroom_species_path(format: :json), params: {
        mushroom_species: {
          mushroom_id: @owner_mushroom.id,
          species_id: @species.id
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "non-admin cannot attach tree to another user's mushroom" do
    sign_in @user

    assert_no_difference("MushroomTree.count") do
      post mushroom_trees_path(format: :json), params: {
        mushroom_tree: {
          mushroom_id: @owner_mushroom.id,
          tree_id: @tree.id
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "non-admin cannot attach plant to another user's mushroom" do
    sign_in @user

    assert_no_difference("MushroomPlant.count") do
      post mushroom_plants_path(format: :json), params: {
        mushroom_plant: {
          mushroom_id: @owner_mushroom.id,
          plant_id: @plant.id
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "non-admin cannot move an image to another user's mushroom" do
    sign_in @user

    image = image_mushrooms(:two) # belongs to @user_mushroom

    patch image_mushroom_path(image), params: {
      image_mushroom: {
        mushroom_id: @owner_mushroom.id
      }
    }

    assert_redirected_to edit_mushroom_image_mushroom_path(image.mushroom_id, image)
    assert_equal @user_mushroom.id, image.reload.mushroom_id
  end
end
