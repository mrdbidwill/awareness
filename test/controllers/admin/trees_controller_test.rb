require "test_helper"

class TreesControllerTest < ActionDispatch::IntegrationTest

  setup do
    @user = users(:one) # Reference your user fixture
    @tree = trees(:one) # Reference your tree fixture
    sign_in @user # Devise helper to sign in the user
  end


  test "should get index" do
    get admin_trees_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_tree_url
    assert_response :success
  end

  test "should create tree" do
    assert_difference("Tree.count") do
      post admin_trees_url, params: { tree: { comments: @tree.comments, description: @tree.description, name: @tree.name } }
    end

    assert_redirected_to admin_tree_url(Tree.last)
  end

  test "should show tree" do
    get admin_tree_url(@tree)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_tree_url(@tree)
    assert_response :success
  end

  test "should update tree" do
    patch admin_tree_url(@tree), params: { tree: { comments: @tree.comments, description: @tree.description, name: @tree.name } }
    assert_redirected_to admin_tree_url(@tree)
  end

  test "should destroy tree" do
    assert_difference("Tree.count", -1) do
      delete admin_tree_url(@tree)
    end

    assert_redirected_to admin_trees_url
  end
end
