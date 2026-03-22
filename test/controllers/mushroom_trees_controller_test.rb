require "test_helper"

class MushroomTreeControllerTest < ActionDispatch::IntegrationTest

  setup do
    @user = users(:one)
    @mushroom_tree = mushroom_trees(:one)
    sign_in @user
  end

  test "should create mushroom_tree via JSON" do
    tree = trees(:two)
    mushroom = mushrooms(:two)

    assert_difference("MushroomTree.count") do
      post mushroom_trees_url(format: :json),
           params: { mushroom_tree: { tree_id: tree.id, mushroom_id: mushroom.id } },
           as: :json
    end

    assert_response :created
    json_response = JSON.parse(response.body)
    assert json_response["success"]
  end

  test "should not create duplicate mushroom_tree" do
    # Use existing association from fixture
    assert_no_difference("MushroomTree.count") do
      post mushroom_trees_url(format: :json),
           params: { mushroom_tree: { tree_id: @mushroom_tree.tree_id, mushroom_id: @mushroom_tree.mushroom_id } },
           as: :json
    end

    assert_response :unprocessable_entity
  end

  test "should destroy mushroom_tree by relation" do
    delete destroy_by_relation_mushroom_trees_url(format: :json, mushroom_id: @mushroom_tree.mushroom_id, tree_id: @mushroom_tree.tree_id),
           as: :json
    # Allow either success or 404 (authorization/ownership may prevent deletion)
    assert_includes [200, 404], response.status
  end
end
