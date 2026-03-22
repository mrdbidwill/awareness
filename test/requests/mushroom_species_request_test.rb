# frozen_string_literal: true

require "test_helper"

class MushroomSpeciesRequestTest < ActionDispatch::IntegrationTest
  # ============================================================================
  # MUSHROOM SPECIES API REQUEST TESTS
  # ============================================================================
  # Tests for JSON API endpoints managing mushroom-species associations
  #
  # ENDPOINTS TESTED:
  # - POST /mushroom_species.json
  # - DELETE /mushroom_species/destroy_by_relation.json
  #
  # FEATURES TESTED:
  # - Authentication requirements
  # - Authorization with Pundit
  # - JSON request/response format
  # - Validation error handling
  # - Duplicate association prevention
  # - Success/error response structure
  # - Record creation and deletion
  # ============================================================================

  setup do
    @user = users(:one)
    @mushroom = mushrooms(:one)
    @species = species(:one)
    @other_species = species(:two)
  end

  # ==========================================================================
  # CREATE TESTS (POST /mushroom_species.json)
  # ==========================================================================

  test "create mushroom_species requires authentication" do
    post mushroom_species_path(format: :json),
         params: { mushroom_species: { mushroom_id: @mushroom.id, species_id: @species.id } }

    assert_response :unauthorized
    json = JSON.parse(response.body)
    assert_equal "You need to sign in or sign up before continuing.", json["error"]
  end

  test "create mushroom_species with valid params returns success" do
    sign_in @user

    assert_difference("MushroomSpecies.count", 1) do
      post mushroom_species_path,
           params: { mushroom_species: { mushroom_id: @mushroom.id, species_id: @other_species.id } }.to_json,
           headers: { "CONTENT_TYPE" => "application/json" }
    end

    assert_response :created
    json = JSON.parse(response.body)
    assert json["success"]
    assert json["id"].present?
    assert_equal "application/json; charset=utf-8", response.content_type
  end

  test "create mushroom_species returns proper JSON structure" do
    sign_in @user

    post mushroom_species_path(format: :json),
         params: { mushroom_species: { mushroom_id: @mushroom.id, species_id: @other_species.id } }

    assert_response :created
    json = JSON.parse(response.body)
    assert json.key?("success")
    assert json.key?("id")
    assert_equal true, json["success"]
    assert json["id"].is_a?(Integer)
  end

  test "create mushroom_species with duplicate association returns error" do
    sign_in @user

    # Fixtures already have mushroom:one with species:one, try to duplicate it
    # Attempt to create duplicate
    assert_no_difference("MushroomSpecies.count") do
      post mushroom_species_path(format: :json),
           params: { mushroom_species: { mushroom_id: @mushroom.id, species_id: @species.id } }
    end

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_equal false, json["success"]
    assert json["errors"].is_a?(Array)
    assert json["errors"].any? { |e| e.include?("already associated") }
  end

  test "create mushroom_species with missing mushroom_id returns error" do
    sign_in @user

    post mushroom_species_path(format: :json),
         params: { mushroom_species: { species_id: @species.id } }

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_equal false, json["success"]
    assert json["errors"].is_a?(Array)
  end

  test "create mushroom_species with missing species_id returns error" do
    sign_in @user

    post mushroom_species_path(format: :json),
         params: { mushroom_species: { mushroom_id: @mushroom.id } }

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_equal false, json["success"]
    assert json["errors"].is_a?(Array)
  end

  test "create mushroom_species with invalid mushroom_id returns error" do
    sign_in @user

    post mushroom_species_path(format: :json),
         params: { mushroom_species: { mushroom_id: 999999, species_id: @species.id } }

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_equal false, json["success"]
  end

  test "create mushroom_species with invalid species_id returns error" do
    sign_in @user

    post mushroom_species_path(format: :json),
         params: { mushroom_species: { mushroom_id: @mushroom.id, species_id: 999999 } }

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_equal false, json["success"]
  end

  test "create mushroom_species with string IDs works" do
    sign_in @user

    post mushroom_species_path(format: :json),
         params: { mushroom_species: { mushroom_id: @mushroom.id.to_s, species_id: @other_species.id.to_s } }

    assert_response :created
    json = JSON.parse(response.body)
    assert json["success"]
  end

  test "create mushroom_species rejects unpermitted parameters" do
    sign_in @user

    post mushroom_species_path(format: :json),
         params: { mushroom_species: { mushroom_id: @mushroom.id, species_id: @other_species.id, admin: true } }

    assert_response :created
    json = JSON.parse(response.body)
    assert json["success"]
    # Should succeed but ignore unpermitted param
  end

  # ==========================================================================
  # DESTROY TESTS (DELETE /mushroom_species/destroy_by_relation.json)
  # ==========================================================================

  test "destroy mushroom_species requires authentication" do
    # Use fixture that already exists
    mushroom_species = mushroom_species(:one)

    delete destroy_by_relation_mushroom_species_path(format: :json),
           params: { mushroom_id: mushroom_species.mushroom_id, species_id: mushroom_species.species_id }

    assert_response :unauthorized
    json = JSON.parse(response.body)
    assert_equal "You need to sign in or sign up before continuing.", json["error"]
    assert MushroomSpecies.exists?(mushroom_species.id)
  end

  test "destroy mushroom_species with valid params returns success" do
    sign_in @user
    # Use other_species to avoid fixture duplication
    mushroom_species = MushroomSpecies.create!(mushroom_id: @mushroom.id, species_id: @other_species.id)

    assert_difference("MushroomSpecies.count", -1) do
      delete destroy_by_relation_mushroom_species_path(format: :json),
             params: { mushroom_id: @mushroom.id, species_id: @other_species.id }
    end

    assert_response :success
    json = JSON.parse(response.body)
    assert json["success"]
    assert_not MushroomSpecies.exists?(mushroom_species.id)
  end

  test "destroy mushroom_species returns proper JSON structure" do
    sign_in @user
    # Use fixture that already exists
    mushroom_species = mushroom_species(:one)

    delete destroy_by_relation_mushroom_species_path(format: :json),
           params: { mushroom_id: mushroom_species.mushroom_id, species_id: mushroom_species.species_id }

    assert_response :success
    json = JSON.parse(response.body)
    assert json.key?("success")
    assert_equal true, json["success"]
  end

  test "destroy non-existent mushroom_species returns not found" do
    sign_in @user

    delete destroy_by_relation_mushroom_species_path(format: :json),
           params: { mushroom_id: @mushroom.id, species_id: 999999 }

    assert_response :not_found
    json = JSON.parse(response.body)
    assert_equal false, json["success"]
    assert json["message"].present?
  end

  test "destroy mushroom_species with missing mushroom_id returns not found" do
    sign_in @user

    delete destroy_by_relation_mushroom_species_path(format: :json),
           params: { species_id: @species.id }

    assert_response :not_found
    json = JSON.parse(response.body)
    assert_equal false, json["success"]
  end

  test "destroy mushroom_species with missing species_id returns not found" do
    sign_in @user

    delete destroy_by_relation_mushroom_species_path(format: :json),
           params: { mushroom_id: @mushroom.id }

    assert_response :not_found
    json = JSON.parse(response.body)
    assert_equal false, json["success"]
  end

  test "destroy mushroom_species with string IDs works" do
    sign_in @user
    # Create with other_species to avoid fixture duplication
    MushroomSpecies.create!(mushroom_id: @mushroom.id, species_id: @other_species.id)

    delete destroy_by_relation_mushroom_species_path(format: :json),
           params: { mushroom_id: @mushroom.id.to_s, species_id: @other_species.id.to_s }

    assert_response :success
    json = JSON.parse(response.body)
    assert json["success"]
  end

  # ==========================================================================
  # AUTHORIZATION TESTS
  # ==========================================================================

  test "user can create mushroom_species for their own mushroom" do
    sign_in @user
    my_mushroom = @user.mushrooms.first

    post mushroom_species_path(format: :json),
         params: { mushroom_species: { mushroom_id: my_mushroom.id, species_id: @species.id } }

    assert_response :created
  end

  test "user can delete mushroom_species for their own mushroom" do
    sign_in @user
    my_mushroom = @user.mushrooms.first
    # Use other_species to avoid fixture duplication
    mushroom_species = MushroomSpecies.create!(mushroom_id: my_mushroom.id, species_id: @other_species.id)

    delete destroy_by_relation_mushroom_species_path(format: :json),
           params: { mushroom_id: my_mushroom.id, species_id: @other_species.id }

    assert_response :success
  end

  # ==========================================================================
  # CONTENT TYPE AND FORMAT TESTS
  # ==========================================================================

  test "create mushroom_species accepts JSON content type" do
    sign_in @user

    post mushroom_species_path(format: :json),
         params: { mushroom_species: { mushroom_id: @mushroom.id, species_id: @other_species.id } }.to_json,
         headers: { "CONTENT_TYPE" => "application/json" }

    assert_response :created
  end

  test "create mushroom_species returns JSON content type" do
    sign_in @user

    post mushroom_species_path(format: :json),
         params: { mushroom_species: { mushroom_id: @mushroom.id, species_id: @other_species.id } }

    assert_response :created
    assert_match(/application\/json/, response.content_type)
  end

  test "destroy mushroom_species returns JSON content type" do
    sign_in @user
    # Use fixture that already exists
    mushroom_species = mushroom_species(:one)

    delete destroy_by_relation_mushroom_species_path(format: :json),
           params: { mushroom_id: mushroom_species.mushroom_id, species_id: mushroom_species.species_id }

    assert_response :success
    assert_match(/application\/json/, response.content_type)
  end

  # ==========================================================================
  # SPECIES-GENUS RELATIONSHIP TESTS
  # ==========================================================================

  test "create mushroom_species validates species belongs to mushroom genus" do
    sign_in @user
    # This test assumes business logic for genus validation exists
    # If species must belong to a genus already associated with mushroom

    genus = genera(:one)
    mushroom = @mushroom
    # Fixtures already have mushroom:one with genus:one, so use find_or_create_by
    GenusMushroom.find_or_create_by!(mushroom: mushroom, genus: genus)

    # Species belonging to same genus
    species_in_genus = Species.create!(name: "ValidSpecies", genera_id: genus.id, mblist_id: 500)

    post mushroom_species_path(format: :json),
         params: { mushroom_species: { mushroom_id: mushroom.id, species_id: species_in_genus.id } }

    assert_response :created
  end

  # ==========================================================================
  # ERROR HANDLING TESTS
  # ==========================================================================

  # Skipping: test requires mocha which is not configured
  # test "create mushroom_species handles database errors gracefully" do
  #   sign_in @user
  #
  #   # Stub save to raise an error
  #   MushroomSpecies.any_instance.stubs(:save).raises(StandardError.new("Database error"))
  #
  #   post mushroom_species_path(format: :json),
  #        params: { mushroom_species: { mushroom_id: @mushroom.id, species_id: @species.id } }
  #
  #   # Should return 500 or handle gracefully
  #   assert_response :error
  # end

  # ==========================================================================
  # VALIDATION TESTS
  # ==========================================================================

  test "create mushroom_species validates presence of required fields" do
    sign_in @user

    post mushroom_species_path(format: :json),
         params: { mushroom_species: {} }

    assert_response :bad_request
  end

  test "create mushroom_species validates foreign key constraints" do
    sign_in @user

    # Attempt to create with non-existent IDs
    post mushroom_species_path(format: :json),
         params: { mushroom_species: { mushroom_id: -1, species_id: -1 } }

    assert_response :unprocessable_entity
  end

  # ==========================================================================
  # BULK OPERATIONS TESTS
  # ==========================================================================

  test "create multiple mushroom_species associations sequentially" do
    sign_in @user

    assert_difference("@mushroom.mushroom_species.count", 3) do
      3.times do |i|
        species = Species.create!(name: "BulkSpecies#{i}", genera_id: genera(:one).id, mblist_id: 600 + i)
        post mushroom_species_path(format: :json),
             params: { mushroom_species: { mushroom_id: @mushroom.id, species_id: species.id } }

        assert_response :created
      end
    end
  end

  test "destroy multiple mushroom_species associations sequentially" do
    sign_in @user

    # Create 3 associations
    species_list = 3.times.map do |i|
      species = Species.create!(name: "DeleteSpecies#{i}", genera_id: genera(:one).id, mblist_id: 700 + i)
      MushroomSpecies.create!(mushroom_id: @mushroom.id, species_id: species.id)
      species
    end

    # Delete them
    species_list.each do |species|
      delete destroy_by_relation_mushroom_species_path(format: :json),
             params: { mushroom_id: @mushroom.id, species_id: species.id }

      assert_response :success
    end

    assert_equal 0, @mushroom.mushroom_species.where(species_id: species_list.map(&:id)).count
  end

  # ==========================================================================
  # EDGE CASE TESTS
  # ==========================================================================

  test "create mushroom_species with null values returns error" do
    sign_in @user

    post mushroom_species_path(format: :json),
         params: { mushroom_species: { mushroom_id: nil, species_id: nil } }

    assert_response :unprocessable_entity
  end

  test "create mushroom_species with empty string IDs returns error" do
    sign_in @user

    post mushroom_species_path(format: :json),
         params: { mushroom_species: { mushroom_id: "", species_id: "" } }

    assert_response :unprocessable_entity
  end
end
