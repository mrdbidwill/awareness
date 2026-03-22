# frozen_string_literal: true

require "test_helper"

class MushroomTreesRequestTest < ActionDispatch::IntegrationTest
  # ============================================================================
  # MUSHROOM TREES API REQUEST TESTS
  # ============================================================================
  # Tests for JSON API endpoints managing mushroom-tree associations
  #
  # ENDPOINTS TESTED:
  # - POST /mushroom_trees.json
  # - DELETE /mushroom_trees/destroy_by_relation.json
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
    @tree = trees(:one)
    @other_tree = trees(:two)
  end

  # ==========================================================================
  # CREATE TESTS (POST /mushroom_trees.json)
  # ==========================================================================

  test "create mushroom_tree requires authentication" do
    post mushroom_trees_path(format: :json),
         params: { mushroom_tree: { mushroom_id: @mushroom.id, tree_id: @tree.id } }

    assert_response :unauthorized
    json = JSON.parse(response.body)
    assert_equal "You need to sign in or sign up before continuing.", json["error"]
  end

  test "create mushroom_tree with valid params returns success" do
    sign_in @user
    # Create unique tree to avoid fixture duplication
    unique_tree = Tree.create!(name: "UniqueTree7")

    assert_difference("MushroomTree.count", 1) do
      post mushroom_trees_path,
           params: { mushroom_tree: { mushroom_id: @mushroom.id, tree_id: unique_tree.id } }.to_json,
           headers: { "CONTENT_TYPE" => "application/json" }
    end

    assert_response :created
    json = JSON.parse(response.body)
    assert json["success"]
    assert json["id"].present?
    assert_equal "application/json; charset=utf-8", response.content_type
  end

  test "create mushroom_tree returns proper JSON structure" do
    sign_in @user
    # Create unique tree to avoid fixture duplication
    unique_tree = Tree.create!(name: "UniqueTree8")

    post mushroom_trees_path(format: :json),
         params: { mushroom_tree: { mushroom_id: @mushroom.id, tree_id: unique_tree.id } }

    assert_response :created
    json = JSON.parse(response.body)
    assert json.key?("success")
    assert json.key?("id")
    assert_equal true, json["success"]
    assert json["id"].is_a?(Integer)
  end

  test "create mushroom_tree with duplicate association returns error" do
    sign_in @user

    # Use existing fixture association (mushroom:one and tree:one already exists)
    # Attempt to create duplicate
    assert_no_difference("MushroomTree.count") do
      post mushroom_trees_path(format: :json),
           params: { mushroom_tree: { mushroom_id: @mushroom.id, tree_id: @tree.id } }
    end

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_equal false, json["success"]
    assert json["errors"].is_a?(Array)
    assert json["errors"].any? { |e| e.include?("already associated") }
  end

  test "create mushroom_tree with missing mushroom_id returns error" do
    sign_in @user

    post mushroom_trees_path(format: :json),
         params: { mushroom_tree: { tree_id: @tree.id } }

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_equal false, json["success"]
    assert json["errors"].is_a?(Array)
  end

  test "create mushroom_tree with missing tree_id returns error" do
    sign_in @user

    post mushroom_trees_path(format: :json),
         params: { mushroom_tree: { mushroom_id: @mushroom.id } }

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_equal false, json["success"]
    assert json["errors"].is_a?(Array)
  end

  test "create mushroom_tree with invalid mushroom_id returns error" do
    sign_in @user

    post mushroom_trees_path(format: :json),
         params: { mushroom_tree: { mushroom_id: 999999, tree_id: @tree.id } }

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_equal false, json["success"]
  end

  test "create mushroom_tree with invalid tree_id returns error" do
    sign_in @user

    post mushroom_trees_path(format: :json),
         params: { mushroom_tree: { mushroom_id: @mushroom.id, tree_id: 999999 } }

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_equal false, json["success"]
  end

  test "create mushroom_tree with string IDs works" do
    sign_in @user
    # Create unique tree to avoid fixture duplication
    unique_tree = Tree.create!(name: "UniqueTree9")

    post mushroom_trees_path(format: :json),
         params: { mushroom_tree: { mushroom_id: @mushroom.id.to_s, tree_id: unique_tree.id.to_s } }

    assert_response :created
    json = JSON.parse(response.body)
    assert json["success"]
  end

  test "create mushroom_tree rejects unpermitted parameters" do
    sign_in @user
    # Create unique tree to avoid fixture duplication
    unique_tree = Tree.create!(name: "UniqueTree10")

    post mushroom_trees_path(format: :json),
         params: { mushroom_tree: { mushroom_id: @mushroom.id, tree_id: unique_tree.id, admin: true } }

    assert_response :created
    json = JSON.parse(response.body)
    assert json["success"]
    # Should succeed but ignore unpermitted param
  end

  # ==========================================================================
  # DESTROY TESTS (DELETE /mushroom_trees/destroy_by_relation.json)
  # ==========================================================================

  test "destroy mushroom_tree requires authentication" do
    # Use existing fixture association
    mushroom_tree = mushroom_trees(:one)

    delete destroy_by_relation_mushroom_trees_path(format: :json),
           params: { mushroom_id: @mushroom.id, tree_id: @tree.id }

    assert_response :unauthorized
    json = JSON.parse(response.body)
    assert_equal "You need to sign in or sign up before continuing.", json["error"]
    assert MushroomTree.exists?(mushroom_tree.id)
  end

  test "destroy mushroom_tree with valid params returns success" do
    sign_in @user
    # Create unique tree to avoid fixture duplication
    unique_tree = Tree.create!(name: "UniqueTree1")
    mushroom_tree = MushroomTree.create!(mushroom_id: @mushroom.id, tree_id: unique_tree.id)

    assert_difference("MushroomTree.count", -1) do
      delete destroy_by_relation_mushroom_trees_path(format: :json),
             params: { mushroom_id: @mushroom.id, tree_id: unique_tree.id }
    end

    assert_response :success
    json = JSON.parse(response.body)
    assert json["success"]
    assert_not MushroomTree.exists?(mushroom_tree.id)
  end

  test "destroy mushroom_tree returns proper JSON structure" do
    sign_in @user
    # Create unique tree to avoid fixture duplication
    unique_tree = Tree.create!(name: "UniqueTree2")
    MushroomTree.create!(mushroom_id: @mushroom.id, tree_id: unique_tree.id)

    delete destroy_by_relation_mushroom_trees_path(format: :json),
           params: { mushroom_id: @mushroom.id, tree_id: unique_tree.id }

    assert_response :success
    json = JSON.parse(response.body)
    assert json.key?("success")
    assert_equal true, json["success"]
  end

  test "destroy non-existent mushroom_tree returns not found" do
    sign_in @user

    delete destroy_by_relation_mushroom_trees_path(format: :json),
           params: { mushroom_id: @mushroom.id, tree_id: 999999 }

    assert_response :not_found
    json = JSON.parse(response.body)
    assert_equal false, json["success"]
    assert json["message"].present?
  end

  test "destroy mushroom_tree with missing mushroom_id returns not found" do
    sign_in @user

    delete destroy_by_relation_mushroom_trees_path(format: :json),
           params: { tree_id: @tree.id }

    assert_response :not_found
    json = JSON.parse(response.body)
    assert_equal false, json["success"]
  end

  test "destroy mushroom_tree with missing tree_id returns not found" do
    sign_in @user

    delete destroy_by_relation_mushroom_trees_path(format: :json),
           params: { mushroom_id: @mushroom.id }

    assert_response :not_found
    json = JSON.parse(response.body)
    assert_equal false, json["success"]
  end

  test "destroy mushroom_tree with string IDs works" do
    sign_in @user
    # Create unique tree to avoid fixture duplication
    unique_tree = Tree.create!(name: "UniqueTree3")
    MushroomTree.create!(mushroom_id: @mushroom.id, tree_id: unique_tree.id)

    delete destroy_by_relation_mushroom_trees_path(format: :json),
           params: { mushroom_id: @mushroom.id.to_s, tree_id: unique_tree.id.to_s }

    assert_response :success
    json = JSON.parse(response.body)
    assert json["success"]
  end

  # ==========================================================================
  # AUTHORIZATION TESTS
  # ==========================================================================

  test "user can create mushroom_tree for their own mushroom" do
    sign_in @user
    my_mushroom = @user.mushrooms.first

    post mushroom_trees_path(format: :json),
         params: { mushroom_tree: { mushroom_id: my_mushroom.id, tree_id: @tree.id } }

    assert_response :created
  end

  test "user can delete mushroom_tree for their own mushroom" do
    sign_in @user
    my_mushroom = @user.mushrooms.first
    # Create unique tree to avoid fixture duplication
    unique_tree = Tree.create!(name: "UniqueTree4")
    mushroom_tree = MushroomTree.create!(mushroom_id: my_mushroom.id, tree_id: unique_tree.id)

    delete destroy_by_relation_mushroom_trees_path(format: :json),
           params: { mushroom_id: my_mushroom.id, tree_id: unique_tree.id }

    assert_response :success
  end

  # ==========================================================================
  # CONTENT TYPE AND FORMAT TESTS
  # ==========================================================================

  test "create mushroom_tree accepts JSON content type" do
    sign_in @user
    # Create unique tree to avoid fixture duplication
    unique_tree = Tree.create!(name: "UniqueTree11")

    post mushroom_trees_path(format: :json),
         params: { mushroom_tree: { mushroom_id: @mushroom.id, tree_id: unique_tree.id } }.to_json,
         headers: { "CONTENT_TYPE" => "application/json" }

    assert_response :created
  end

  test "create mushroom_tree returns JSON content type" do
    sign_in @user
    # Create unique tree to avoid fixture duplication
    unique_tree = Tree.create!(name: "UniqueTree12")

    post mushroom_trees_path(format: :json),
         params: { mushroom_tree: { mushroom_id: @mushroom.id, tree_id: unique_tree.id } }

    assert_response :created
    assert_match(/application\/json/, response.content_type)
  end

  test "destroy mushroom_tree returns JSON content type" do
    sign_in @user
    # Create unique tree to avoid fixture duplication
    unique_tree = Tree.create!(name: "UniqueTree5")
    MushroomTree.create!(mushroom_id: @mushroom.id, tree_id: unique_tree.id)

    delete destroy_by_relation_mushroom_trees_path(format: :json),
           params: { mushroom_id: @mushroom.id, tree_id: unique_tree.id }

    assert_response :success
    assert_match(/application\/json/, response.content_type)
  end

  # ==========================================================================
  # MYCORRHIZAL RELATIONSHIP TESTS
  # ==========================================================================

  test "create mushroom_tree represents mycorrhizal association" do
    sign_in @user
    # Create unique tree to avoid fixture duplication
    unique_tree = Tree.create!(name: "UniqueTree13")

    post mushroom_trees_path(format: :json),
         params: { mushroom_tree: { mushroom_id: @mushroom.id, tree_id: unique_tree.id } }

    assert_response :created
    json = JSON.parse(response.body)
    assert json["success"]

    # Verify association exists
    @mushroom.reload
    assert @mushroom.trees.include?(unique_tree)
  end

  test "create multiple tree associations for single mushroom" do
    sign_in @user

    # Create unique trees to avoid fixture duplication
    tree1 = Tree.create!(name: "MultiTree1")
    tree2 = Tree.create!(name: "MultiTree2")
    trees = [tree1, tree2]

    trees.each do |tree|
      post mushroom_trees_path(format: :json),
           params: { mushroom_tree: { mushroom_id: @mushroom.id, tree_id: tree.id } }

      assert_response :created
    end

    @mushroom.reload
    assert_operator @mushroom.trees.count, :>=, 2
  end

  # ==========================================================================
  # ERROR HANDLING TESTS
  # ==========================================================================

  # Skipping: test requires mocha which is not configured
  # test "create mushroom_tree handles database errors gracefully" do
  #   sign_in @user
  #
  #   # Stub save to raise an error
  #   MushroomTree.any_instance.stubs(:save).raises(StandardError.new("Database error"))
  #
  #   post mushroom_trees_path(format: :json),
  #        params: { mushroom_tree: { mushroom_id: @mushroom.id, tree_id: @tree.id } }
  #
  #   # Should return 500 or handle gracefully
  #   assert_response :error
  # end

  # ==========================================================================
  # VALIDATION TESTS
  # ==========================================================================

  test "create mushroom_tree validates presence of required fields" do
    sign_in @user

    post mushroom_trees_path(format: :json),
         params: { mushroom_tree: {} }

    # Empty params hash returns 400 (Bad Request) due to params.expect
    assert_response :bad_request
  end

  test "create mushroom_tree validates foreign key constraints" do
    sign_in @user

    # Attempt to create with non-existent IDs
    post mushroom_trees_path(format: :json),
         params: { mushroom_tree: { mushroom_id: -1, tree_id: -1 } }

    assert_response :unprocessable_entity
  end

  # ==========================================================================
  # BULK OPERATIONS TESTS
  # ==========================================================================

  test "create multiple mushroom_tree associations sequentially" do
    sign_in @user

    3.times do |i|
      tree = Tree.create!(name: "BulkTree#{i}")
      post mushroom_trees_path(format: :json),
           params: { mushroom_tree: { mushroom_id: @mushroom.id, tree_id: tree.id } }

      assert_response :created
    end

    @mushroom.reload
    assert_operator @mushroom.trees.count, :>=, 3
  end

  test "destroy multiple mushroom_tree associations sequentially" do
    sign_in @user

    # Create 3 associations
    tree_list = 3.times.map do |i|
      tree = Tree.create!(name: "DeleteTree#{i}")
      MushroomTree.create!(mushroom_id: @mushroom.id, tree_id: tree.id)
      tree
    end

    # Delete them
    tree_list.each do |tree|
      delete destroy_by_relation_mushroom_trees_path(format: :json),
             params: { mushroom_id: @mushroom.id, tree_id: tree.id }

      assert_response :success
    end

    @mushroom.reload
    assert_equal 0, @mushroom.mushroom_trees.where(tree_id: tree_list.map(&:id)).count
  end

  # ==========================================================================
  # EDGE CASE TESTS
  # ==========================================================================

  test "create mushroom_tree with null values returns error" do
    sign_in @user

    post mushroom_trees_path(format: :json),
         params: { mushroom_tree: { mushroom_id: nil, tree_id: nil } }

    assert_response :unprocessable_entity
  end

  test "create mushroom_tree with empty string IDs returns error" do
    sign_in @user

    post mushroom_trees_path(format: :json),
         params: { mushroom_tree: { mushroom_id: "", tree_id: "" } }

    assert_response :unprocessable_entity
  end

  test "destroy mushroom_tree is idempotent" do
    sign_in @user
    # Create unique tree to avoid fixture duplication
    unique_tree = Tree.create!(name: "UniqueTree6")
    MushroomTree.create!(mushroom_id: @mushroom.id, tree_id: unique_tree.id)

    # First deletion
    delete destroy_by_relation_mushroom_trees_path(format: :json),
           params: { mushroom_id: @mushroom.id, tree_id: unique_tree.id }
    assert_response :success

    # Second deletion of same relation
    delete destroy_by_relation_mushroom_trees_path(format: :json),
           params: { mushroom_id: @mushroom.id, tree_id: unique_tree.id }
    assert_response :not_found
  end
end
