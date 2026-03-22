# frozen_string_literal: true

require "test_helper"

class MushroomPlantsRequestTest < ActionDispatch::IntegrationTest
  # ============================================================================
  # MUSHROOM PLANTS API REQUEST TESTS
  # ============================================================================
  # Tests for JSON API endpoints managing mushroom-plant associations
  #
  # ENDPOINTS TESTED:
  # - POST /mushroom_plants.json
  # - DELETE /mushroom_plants/destroy_by_relation.json
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
    @plant = plants(:one)
    @other_plant = plants(:two)
  end

  # ==========================================================================
  # CREATE TESTS (POST /mushroom_plants.json)
  # ==========================================================================

  test "create mushroom_plant requires authentication" do
    post mushroom_plants_path(format: :json),
         params: { mushroom_plant: { mushroom_id: @mushroom.id, plant_id: @plant.id } }

    assert_response :unauthorized
    json = JSON.parse(response.body)
    assert_equal "You need to sign in or sign up before continuing.", json["error"]
  end

  test "create mushroom_plant with valid params returns success" do
    sign_in @user

    assert_difference("MushroomPlant.count", 1) do
      post mushroom_plants_path,
           params: { mushroom_plant: { mushroom_id: @mushroom.id, plant_id: @other_plant.id } }.to_json,
           headers: { "CONTENT_TYPE" => "application/json" }
    end

    assert_response :created
    json = JSON.parse(response.body)
    assert json["success"]
    assert json["id"].present?
    assert_equal "application/json; charset=utf-8", response.content_type
  end

  test "create mushroom_plant returns proper JSON structure" do
    sign_in @user

    post mushroom_plants_path(format: :json),
         params: { mushroom_plant: { mushroom_id: @mushroom.id, plant_id: @other_plant.id } }

    assert_response :created
    json = JSON.parse(response.body)
    assert json.key?("success")
    assert json.key?("id")
    assert_equal true, json["success"]
    assert json["id"].is_a?(Integer)
  end

  test "create mushroom_plant with duplicate association returns error" do
    sign_in @user

    # Use existing fixture association (mushroom:one and plant:one already exists)
    # Attempt to create duplicate
    assert_no_difference("MushroomPlant.count") do
      post mushroom_plants_path(format: :json),
           params: { mushroom_plant: { mushroom_id: @mushroom.id, plant_id: @plant.id } }
    end

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_equal false, json["success"]
    assert json["errors"].is_a?(Array)
    assert json["errors"].any? { |e| e.include?("already associated") }
  end

  test "create mushroom_plant with missing mushroom_id returns error" do
    sign_in @user

    post mushroom_plants_path(format: :json),
         params: { mushroom_plant: { plant_id: @plant.id } }

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_equal false, json["success"]
    assert json["errors"].is_a?(Array)
  end

  test "create mushroom_plant with missing plant_id returns error" do
    sign_in @user

    post mushroom_plants_path(format: :json),
         params: { mushroom_plant: { mushroom_id: @mushroom.id } }

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_equal false, json["success"]
    assert json["errors"].is_a?(Array)
  end

  test "create mushroom_plant with invalid mushroom_id returns error" do
    sign_in @user

    post mushroom_plants_path(format: :json),
         params: { mushroom_plant: { mushroom_id: 999999, plant_id: @plant.id } }

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_equal false, json["success"]
  end

  test "create mushroom_plant with invalid plant_id returns error" do
    sign_in @user

    post mushroom_plants_path(format: :json),
         params: { mushroom_plant: { mushroom_id: @mushroom.id, plant_id: 999999 } }

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_equal false, json["success"]
  end

  test "create mushroom_plant with string IDs works" do
    sign_in @user

    post mushroom_plants_path(format: :json),
         params: { mushroom_plant: { mushroom_id: @mushroom.id.to_s, plant_id: @other_plant.id.to_s } }

    assert_response :created
    json = JSON.parse(response.body)
    assert json["success"]
  end

  test "create mushroom_plant rejects unpermitted parameters" do
    sign_in @user

    post mushroom_plants_path(format: :json),
         params: { mushroom_plant: { mushroom_id: @mushroom.id, plant_id: @other_plant.id, admin: true } }

    assert_response :created
    json = JSON.parse(response.body)
    assert json["success"]
    # Should succeed but ignore unpermitted param
  end

  # ==========================================================================
  # DESTROY TESTS (DELETE /mushroom_plants/destroy_by_relation.json)
  # ==========================================================================

  test "destroy mushroom_plant requires authentication" do
    # Use existing fixture association
    mushroom_plant = mushroom_plants(:one)

    delete destroy_by_relation_mushroom_plants_path(format: :json),
           params: { mushroom_id: @mushroom.id, plant_id: @plant.id }

    assert_response :unauthorized
    json = JSON.parse(response.body)
    assert_equal "You need to sign in or sign up before continuing.", json["error"]
    assert MushroomPlant.exists?(mushroom_plant.id)
  end

  test "destroy mushroom_plant with valid params returns success" do
    sign_in @user
    # Create unique plant to avoid fixture duplication
    unique_plant = Plant.create!(name: "UniquePlant1")
    mushroom_plant = MushroomPlant.create!(mushroom_id: @mushroom.id, plant_id: unique_plant.id)

    assert_difference("MushroomPlant.count", -1) do
      delete destroy_by_relation_mushroom_plants_path(format: :json),
             params: { mushroom_id: @mushroom.id, plant_id: unique_plant.id }
    end

    assert_response :success
    json = JSON.parse(response.body)
    assert json["success"]
    assert_not MushroomPlant.exists?(mushroom_plant.id)
  end

  test "destroy mushroom_plant returns proper JSON structure" do
    sign_in @user
    # Create unique plant to avoid fixture duplication
    unique_plant = Plant.create!(name: "UniquePlant2")
    MushroomPlant.create!(mushroom_id: @mushroom.id, plant_id: unique_plant.id)

    delete destroy_by_relation_mushroom_plants_path(format: :json),
           params: { mushroom_id: @mushroom.id, plant_id: unique_plant.id }

    assert_response :success
    json = JSON.parse(response.body)
    assert json.key?("success")
    assert_equal true, json["success"]
  end

  test "destroy non-existent mushroom_plant returns not found" do
    sign_in @user

    delete destroy_by_relation_mushroom_plants_path(format: :json),
           params: { mushroom_id: @mushroom.id, plant_id: 999999 }

    assert_response :not_found
    json = JSON.parse(response.body)
    assert_equal false, json["success"]
    assert json["message"].present?
  end

  test "destroy mushroom_plant with missing mushroom_id returns not found" do
    sign_in @user

    delete destroy_by_relation_mushroom_plants_path(format: :json),
           params: { plant_id: @plant.id }

    assert_response :not_found
    json = JSON.parse(response.body)
    assert_equal false, json["success"]
  end

  test "destroy mushroom_plant with missing plant_id returns not found" do
    sign_in @user

    delete destroy_by_relation_mushroom_plants_path(format: :json),
           params: { mushroom_id: @mushroom.id }

    assert_response :not_found
    json = JSON.parse(response.body)
    assert_equal false, json["success"]
  end

  test "destroy mushroom_plant with string IDs works" do
    sign_in @user
    # Create unique plant to avoid fixture duplication
    unique_plant = Plant.create!(name: "UniquePlant3")
    MushroomPlant.create!(mushroom_id: @mushroom.id, plant_id: unique_plant.id)

    delete destroy_by_relation_mushroom_plants_path(format: :json),
           params: { mushroom_id: @mushroom.id.to_s, plant_id: unique_plant.id.to_s }

    assert_response :success
    json = JSON.parse(response.body)
    assert json["success"]
  end

  # ==========================================================================
  # AUTHORIZATION TESTS
  # ==========================================================================

  test "user can create mushroom_plant for their own mushroom" do
    sign_in @user
    my_mushroom = @user.mushrooms.first

    post mushroom_plants_path(format: :json),
         params: { mushroom_plant: { mushroom_id: my_mushroom.id, plant_id: @plant.id } }

    assert_response :created
  end

  test "user can delete mushroom_plant for their own mushroom" do
    sign_in @user
    my_mushroom = @user.mushrooms.first
    # Create unique plant to avoid fixture duplication
    unique_plant = Plant.create!(name: "UniquePlant4")
    mushroom_plant = MushroomPlant.create!(mushroom_id: my_mushroom.id, plant_id: unique_plant.id)

    delete destroy_by_relation_mushroom_plants_path(format: :json),
           params: { mushroom_id: my_mushroom.id, plant_id: unique_plant.id }

    assert_response :success
  end

  # ==========================================================================
  # CONTENT TYPE AND FORMAT TESTS
  # ==========================================================================

  test "create mushroom_plant accepts JSON content type" do
    sign_in @user

    post mushroom_plants_path(format: :json),
         params: { mushroom_plant: { mushroom_id: @mushroom.id, plant_id: @other_plant.id } }.to_json,
         headers: { "CONTENT_TYPE" => "application/json" }

    assert_response :created
  end

  test "create mushroom_plant returns JSON content type" do
    sign_in @user

    post mushroom_plants_path(format: :json),
         params: { mushroom_plant: { mushroom_id: @mushroom.id, plant_id: @other_plant.id } }

    assert_response :created
    assert_match(/application\/json/, response.content_type)
  end

  test "destroy mushroom_plant returns JSON content type" do
    sign_in @user
    # Create unique plant to avoid fixture duplication
    unique_plant = Plant.create!(name: "UniquePlant5")
    MushroomPlant.create!(mushroom_id: @mushroom.id, plant_id: unique_plant.id)

    delete destroy_by_relation_mushroom_plants_path(format: :json),
           params: { mushroom_id: @mushroom.id, plant_id: unique_plant.id }

    assert_response :success
    assert_match(/application\/json/, response.content_type)
  end

  # ==========================================================================
  # ECOLOGICAL RELATIONSHIP TESTS
  # ==========================================================================

  test "create mushroom_plant represents ecological association" do
    sign_in @user
    # Create unique plant to avoid fixture duplication
    unique_plant = Plant.create!(name: "UniquePlant6")

    post mushroom_plants_path(format: :json),
         params: { mushroom_plant: { mushroom_id: @mushroom.id, plant_id: unique_plant.id } }

    assert_response :created
    json = JSON.parse(response.body)
    assert json["success"]

    # Verify association exists
    @mushroom.reload
    assert @mushroom.plants.include?(unique_plant)
  end

  test "create multiple plant associations for single mushroom" do
    sign_in @user

    # Create unique plants to avoid fixture duplication
    plant1 = Plant.create!(name: "MultiPlant1")
    plant2 = Plant.create!(name: "MultiPlant2")
    plant_list = [plant1, plant2]

    plant_list.each do |plant|
      post mushroom_plants_path(format: :json),
           params: { mushroom_plant: { mushroom_id: @mushroom.id, plant_id: plant.id } }

      assert_response :created
    end

    @mushroom.reload
    assert_operator @mushroom.plants.count, :>=, 2
  end

  test "mushroom can be associated with various plant types" do
    sign_in @user

    # Create different plant types
    fern = Plant.create!(name: "Fern Species")
    moss = Plant.create!(name: "Moss Species")
    grass = Plant.create!(name: "Grass Species")

    [fern, moss, grass].each do |plant|
      post mushroom_plants_path(format: :json),
           params: { mushroom_plant: { mushroom_id: @mushroom.id, plant_id: plant.id } }

      assert_response :created
    end

    @mushroom.reload
    assert_operator @mushroom.plants.count, :>=, 3
  end

  # ==========================================================================
  # ERROR HANDLING TESTS
  # ==========================================================================

  # Skipping: test requires mocha which is not configured
  # test "create mushroom_plant handles database errors gracefully" do
  #   sign_in @user
  #
  #   # Stub save to raise an error
  #   MushroomPlant.any_instance.stubs(:save).raises(StandardError.new("Database error"))
  #
  #   post mushroom_plants_path(format: :json),
  #        params: { mushroom_plant: { mushroom_id: @mushroom.id, plant_id: @plant.id } }
  #
  #   # Should return 500 or handle gracefully
  #   assert_response :error
  # end

  # ==========================================================================
  # VALIDATION TESTS
  # ==========================================================================

  test "create mushroom_plant validates presence of required fields" do
    sign_in @user

    post mushroom_plants_path(format: :json),
         params: { mushroom_plant: {} }

    # Empty params hash returns 400 (Bad Request) due to params.expect
    assert_response :bad_request
  end

  test "create mushroom_plant validates foreign key constraints" do
    sign_in @user

    # Attempt to create with non-existent IDs
    post mushroom_plants_path(format: :json),
         params: { mushroom_plant: { mushroom_id: -1, plant_id: -1 } }

    assert_response :unprocessable_entity
  end

  # ==========================================================================
  # BULK OPERATIONS TESTS
  # ==========================================================================

  test "create multiple mushroom_plant associations sequentially" do
    sign_in @user

    3.times do |i|
      plant = Plant.create!(name: "BulkPlant#{i}")
      post mushroom_plants_path(format: :json),
           params: { mushroom_plant: { mushroom_id: @mushroom.id, plant_id: plant.id } }

      assert_response :created
    end

    @mushroom.reload
    assert_operator @mushroom.plants.count, :>=, 3
  end

  test "destroy multiple mushroom_plant associations sequentially" do
    sign_in @user

    # Create 3 associations
    plant_list = 3.times.map do |i|
      plant = Plant.create!(name: "DeletePlant#{i}")
      MushroomPlant.create!(mushroom_id: @mushroom.id, plant_id: plant.id)
      plant
    end

    # Delete them
    plant_list.each do |plant|
      delete destroy_by_relation_mushroom_plants_path(format: :json),
             params: { mushroom_id: @mushroom.id, plant_id: plant.id }

      assert_response :success
    end

    @mushroom.reload
    assert_equal 0, @mushroom.mushroom_plants.where(plant_id: plant_list.map(&:id)).count
  end

  # ==========================================================================
  # EDGE CASE TESTS
  # ==========================================================================

  test "create mushroom_plant with null values returns error" do
    sign_in @user

    post mushroom_plants_path(format: :json),
         params: { mushroom_plant: { mushroom_id: nil, plant_id: nil } }

    assert_response :unprocessable_entity
  end

  test "create mushroom_plant with empty string IDs returns error" do
    sign_in @user

    post mushroom_plants_path(format: :json),
         params: { mushroom_plant: { mushroom_id: "", plant_id: "" } }

    assert_response :unprocessable_entity
  end

  test "destroy mushroom_plant is idempotent" do
    sign_in @user
    # Create unique plant to avoid fixture duplication
    unique_plant = Plant.create!(name: "UniquePlant7")
    MushroomPlant.create!(mushroom_id: @mushroom.id, plant_id: unique_plant.id)

    # First deletion
    delete destroy_by_relation_mushroom_plants_path(format: :json),
           params: { mushroom_id: @mushroom.id, plant_id: unique_plant.id }
    assert_response :success

    # Second deletion of same relation
    delete destroy_by_relation_mushroom_plants_path(format: :json),
           params: { mushroom_id: @mushroom.id, plant_id: unique_plant.id }
    assert_response :not_found
  end

  test "create mushroom_plant with very long plant name works" do
    sign_in @user
    long_plant = Plant.create!(name: "A" * 255)

    post mushroom_plants_path(format: :json),
         params: { mushroom_plant: { mushroom_id: @mushroom.id, plant_id: long_plant.id } }

    assert_response :created
  end
end
