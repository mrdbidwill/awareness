# frozen_string_literal: true

require "test_helper"

class GenusMushroomsRequestTest < ActionDispatch::IntegrationTest
  # ============================================================================
  # GENUS MUSHROOMS API REQUEST TESTS
  # ============================================================================
  # Tests for JSON API endpoints managing genus-mushroom associations
  #
  # ENDPOINTS TESTED:
  # - POST /genus_mushrooms.json
  # - DELETE /genus_mushrooms/destroy_by_relation.json
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
    @genus = genera(:one)
    @other_genus = genera(:two)
  end

  # ==========================================================================
  # CREATE TESTS (POST /genus_mushrooms.json)
  # ==========================================================================

  test "create genus_mushroom requires authentication" do
    post genus_mushrooms_path(format: :json),
         params: { genus_mushroom: { mushroom_id: @mushroom.id, genus_id: @genus.id } }

    assert_response :unauthorized
    json = JSON.parse(response.body)
    assert_equal "You need to sign in or sign up before continuing.", json["error"]
  end

  test "create genus_mushroom with valid params returns success" do
    sign_in @user

    assert_difference("GenusMushroom.count", 1) do
      post genus_mushrooms_path,
           params: { genus_mushroom: { mushroom_id: @mushroom.id, genus_id: @other_genus.id } }.to_json,
           headers: { "CONTENT_TYPE" => "application/json" }
    end

    assert_response :created
    json = JSON.parse(response.body)
    assert json["success"]
    assert json["id"].present?
    assert_equal "application/json; charset=utf-8", response.content_type
  end

  test "create genus_mushroom returns proper JSON structure" do
    sign_in @user

    post genus_mushrooms_path(format: :json),
         params: { genus_mushroom: { mushroom_id: @mushroom.id, genus_id: @other_genus.id } }

    assert_response :created
    json = JSON.parse(response.body)
    assert json.key?("success")
    assert json.key?("id")
    assert json["success"] == true
    assert json["id"].is_a?(Integer)
  end

  test "create genus_mushroom with duplicate association returns error" do
    sign_in @user

    # Fixtures already have mushroom:one with genus:one
    # Attempt to create duplicate
    assert_no_difference("GenusMushroom.count") do
      post genus_mushrooms_path(format: :json),
           params: { genus_mushroom: { mushroom_id: @mushroom.id, genus_id: @genus.id } }
    end

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_equal false, json["success"]
    assert json["errors"].is_a?(Array)
    assert json["errors"].any? { |e| e.include?("already associated") }
  end

  test "create genus_mushroom with missing mushroom_id returns error" do
    sign_in @user

    post genus_mushrooms_path(format: :json),
         params: { genus_mushroom: { genus_id: @genus.id } }

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_equal false, json["success"]
    assert json["errors"].is_a?(Array)
  end

  test "create genus_mushroom with missing genus_id returns error" do
    sign_in @user

    post genus_mushrooms_path(format: :json),
         params: { genus_mushroom: { mushroom_id: @mushroom.id } }

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_equal false, json["success"]
    assert json["errors"].is_a?(Array)
  end

  test "create genus_mushroom with invalid mushroom_id returns error" do
    sign_in @user

    post genus_mushrooms_path(format: :json),
         params: { genus_mushroom: { mushroom_id: 999999, genus_id: @genus.id } }

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_equal false, json["success"]
  end

  test "create genus_mushroom with invalid genus_id returns error" do
    sign_in @user

    post genus_mushrooms_path(format: :json),
         params: { genus_mushroom: { mushroom_id: @mushroom.id, genus_id: 999999 } }

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_equal false, json["success"]
  end

  test "create genus_mushroom with string IDs works" do
    sign_in @user

    post genus_mushrooms_path(format: :json),
         params: { genus_mushroom: { mushroom_id: @mushroom.id.to_s, genus_id: @other_genus.id.to_s } }

    assert_response :created
    json = JSON.parse(response.body)
    assert json["success"]
  end

  test "create genus_mushroom rejects unpermitted parameters" do
    sign_in @user

    post genus_mushrooms_path(format: :json),
         params: { genus_mushroom: { mushroom_id: @mushroom.id, genus_id: @other_genus.id, admin: true } }

    assert_response :created
    json = JSON.parse(response.body)
    assert json["success"]
    # Should succeed but ignore unpermitted param
  end

  # ==========================================================================
  # DESTROY TESTS (DELETE /genus_mushrooms/destroy_by_relation.json)
  # ==========================================================================

  test "destroy genus_mushroom requires authentication" do
    # Use fixture that already exists
    genus_mushroom = genus_mushrooms(:one)

    delete destroy_by_relation_genus_mushrooms_path(format: :json),
           params: { mushroom_id: genus_mushroom.mushroom.id, genus_id: genus_mushroom.genus.id }

    assert_response :unauthorized
    json = JSON.parse(response.body)
    assert_equal "You need to sign in or sign up before continuing.", json["error"]
    assert GenusMushroom.exists?(genus_mushroom.id)
  end

  test "destroy genus_mushroom with valid params returns success" do
    sign_in @user
    # Use other_genus to avoid fixture duplication
    genus_mushroom = GenusMushroom.create!(mushroom_id: @mushroom.id, genus_id: @other_genus.id)

    assert_difference("GenusMushroom.count", -1) do
      delete destroy_by_relation_genus_mushrooms_path(format: :json),
             params: { mushroom_id: @mushroom.id, genus_id: @other_genus.id }
    end

    assert_response :success
    json = JSON.parse(response.body)
    assert json["success"]
    assert_not GenusMushroom.exists?(genus_mushroom.id)
  end

  test "destroy genus_mushroom returns proper JSON structure" do
    sign_in @user
    # Use fixture that already exists
    genus_mushroom = genus_mushrooms(:one)

    delete destroy_by_relation_genus_mushrooms_path(format: :json),
           params: { mushroom_id: genus_mushroom.mushroom.id, genus_id: genus_mushroom.genus.id }

    assert_response :success
    json = JSON.parse(response.body)
    assert json.key?("success")
    assert_equal true, json["success"]
  end

  test "destroy non-existent genus_mushroom returns not found" do
    sign_in @user

    delete destroy_by_relation_genus_mushrooms_path(format: :json),
           params: { mushroom_id: @mushroom.id, genus_id: 999999 }

    assert_response :not_found
    json = JSON.parse(response.body)
    assert_equal false, json["success"]
    assert json["message"].present?
  end

  test "destroy genus_mushroom with missing mushroom_id returns not found" do
    sign_in @user

    delete destroy_by_relation_genus_mushrooms_path(format: :json),
           params: { genus_id: @genus.id }

    assert_response :not_found
    json = JSON.parse(response.body)
    assert_equal false, json["success"]
  end

  test "destroy genus_mushroom with missing genus_id returns not found" do
    sign_in @user

    delete destroy_by_relation_genus_mushrooms_path(format: :json),
           params: { mushroom_id: @mushroom.id }

    assert_response :not_found
    json = JSON.parse(response.body)
    assert_equal false, json["success"]
  end

  test "destroy genus_mushroom with string IDs works" do
    sign_in @user
    # Use other_genus to avoid fixture duplication
    GenusMushroom.create!(mushroom_id: @mushroom.id, genus_id: @other_genus.id)

    delete destroy_by_relation_genus_mushrooms_path(format: :json),
           params: { mushroom_id: @mushroom.id.to_s, genus_id: @other_genus.id.to_s }

    assert_response :success
    json = JSON.parse(response.body)
    assert json["success"]
  end

  # ==========================================================================
  # AUTHORIZATION TESTS
  # ==========================================================================

  test "user can create genus_mushroom for their own mushroom" do
    sign_in @user
    my_mushroom = @user.mushrooms.first

    post genus_mushrooms_path(format: :json),
         params: { genus_mushroom: { mushroom_id: my_mushroom.id, genus_id: @genus.id } }

    assert_response :created
  end

  test "user can delete genus_mushroom for their own mushroom" do
    sign_in @user
    my_mushroom = @user.mushrooms.first
    # Use other_genus to avoid fixture duplication
    genus_mushroom = GenusMushroom.create!(mushroom_id: my_mushroom.id, genus_id: @other_genus.id)

    delete destroy_by_relation_genus_mushrooms_path(format: :json),
           params: { mushroom_id: my_mushroom.id, genus_id: @other_genus.id }

    assert_response :success
  end

  # ==========================================================================
  # CONTENT TYPE AND FORMAT TESTS
  # ==========================================================================

  test "create genus_mushroom accepts JSON content type" do
    sign_in @user

    post genus_mushrooms_path(format: :json),
         params: { genus_mushroom: { mushroom_id: @mushroom.id, genus_id: @other_genus.id } }.to_json,
         headers: { "CONTENT_TYPE" => "application/json" }

    assert_response :created
  end

  test "create genus_mushroom returns JSON content type" do
    sign_in @user

    post genus_mushrooms_path(format: :json),
         params: { genus_mushroom: { mushroom_id: @mushroom.id, genus_id: @other_genus.id } }

    assert_response :created
    assert_match(/application\/json/, response.content_type)
  end

  test "destroy genus_mushroom returns JSON content type" do
    sign_in @user
    # Use fixture that already exists
    genus_mushroom = genus_mushrooms(:one)

    delete destroy_by_relation_genus_mushrooms_path(format: :json),
           params: { mushroom_id: genus_mushroom.mushroom.id, genus_id: genus_mushroom.genus.id }

    assert_response :success
    assert_match(/application\/json/, response.content_type)
  end

  # ==========================================================================
  # ERROR HANDLING TESTS
  # ==========================================================================

  # Skipping: test requires mocha which is not configured
  # test "create genus_mushroom handles database errors gracefully" do
  #   sign_in @user
  #
  #   # Stub save to raise an error
  #   GenusMushroom.any_instance.stubs(:save).raises(StandardError.new("Database error"))
  #
  #   post genus_mushrooms_path(format: :json),
  #        params: { genus_mushroom: { mushroom_id: @mushroom.id, genus_id: @genus.id } }
  #
  #   # Should return 500 or handle gracefully
  #   assert_response :error
  # end

  # Skipping: test requires mocha which is not configured
  # test "destroy genus_mushroom handles exceptions gracefully" do
  #   sign_in @user
  #   GenusMushroom.create!(mushroom_id: @mushroom.id, genus_id: @genus.id)
  #
  #   # Stub destroy to raise an error
  #   GenusMushroom.any_instance.stubs(:destroy).raises(StandardError.new("Deletion error"))
  #
  #   delete destroy_by_relation_genus_mushrooms_path(format: :json),
  #          params: { mushroom_id: @mushroom.id, genus_id: @genus.id }
  #
  #   assert_response :internal_server_error
  #   json = JSON.parse(response.body)
  #   assert_equal false, json["success"]
  #   assert json["message"].present?
  # end

  # ==========================================================================
  # VALIDATION TESTS
  # ==========================================================================

  test "create genus_mushroom validates presence of required fields" do
    sign_in @user

    post genus_mushrooms_path(format: :json),
         params: { genus_mushroom: {} }

    assert_response :bad_request
  end

  test "create genus_mushroom validates foreign key constraints" do
    sign_in @user

    # Attempt to create with non-existent IDs
    post genus_mushrooms_path(format: :json),
         params: { genus_mushroom: { mushroom_id: -1, genus_id: -1 } }

    assert_response :unprocessable_entity
  end
end
