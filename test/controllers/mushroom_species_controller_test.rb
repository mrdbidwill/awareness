require "test_helper"

class MushroomSpeciesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @mushroom = mushrooms(:one)
    @species = species(:one)
    @other_species = species(:two)
    sign_in @user
  end

  test "should create mushroom_species as JSON" do
    assert_difference("MushroomSpecies.count") do
      post mushroom_species_url, params: {
        mushroom_species: {
          mushroom_id: @mushroom.id,
          species_id: @other_species.id  # Use other_species to avoid fixture duplication
        }
      }, as: :json
    end

    assert_response :created
    json_response = JSON.parse(response.body)
    assert json_response["success"]
    assert json_response["id"]
  end

  test "should handle duplicate mushroom_species" do
    # Fixtures already have mushroom:one with species:one, try to create duplicate

    # Try to create duplicate
    post mushroom_species_url, params: {
      mushroom_species: {
        mushroom_id: @mushroom.id,
        species_id: @species.id
      }
    }, as: :json

    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert_not json_response["success"]
    assert_includes json_response["errors"], "This species is already associated with this mushroom"
  end

  test "should destroy mushroom_species by relation" do
    mushroom_species = MushroomSpecies.create!(
      mushroom_id: @mushroom.id,
      species_id: @other_species.id  # Use other_species to avoid fixture duplication
    )

    assert_difference("MushroomSpecies.count", -1) do
      delete destroy_by_relation_mushroom_species_url, params: {
        mushroom_id: @mushroom.id,
        species_id: @other_species.id
      }, as: :json
    end

    assert_response :success
    json_response = JSON.parse(response.body)
    assert json_response["success"]
  end

  test "should return not found for non-existent relation" do
    delete destroy_by_relation_mushroom_species_url, params: {
      mushroom_id: 99999,
      species_id: 99999
    }, as: :json

    assert_response :not_found
    json_response = JSON.parse(response.body)
    assert_not json_response["success"]
  end

  test "should require authentication" do
    sign_out @user

    post mushroom_species_url, params: {
      mushroom_species: {
        mushroom_id: @mushroom.id,
        species_id: @species.id
      }
    }, as: :json

    assert_response :unauthorized
  end

  test "should handle invalid params" do
    post mushroom_species_url, params: {
      mushroom_species: {
        mushroom_id: @mushroom.id,
        species_id: nil
      }
    }, as: :json

    assert_response :unprocessable_entity
  end
end
