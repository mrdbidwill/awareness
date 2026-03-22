require "test_helper"

class ClusterMushroomsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @cluster_mushroom = cluster_mushrooms(:one)

    # Sign in user for authentication
    @user = users(:one)
    @user.permission_id = 2
    sign_in @user
  end

  test "should get index" do
    get cluster_mushrooms_path
    assert_response :success
  end

  test "should get new" do
    get '/cluster_mushrooms/new'
    assert_response :success
  end

  test "should create Cluster Mushroom" do
    # Use cluster:two and mushroom:one (both have user:one, not yet associated)
    mushroom = mushrooms(:one)
    cluster = clusters(:two)
    assert_difference("ClusterMushroom.count", 1) do
      post cluster_mushrooms_path, params: {
        cluster_mushroom: {
          cluster_id: cluster.id,
          mushroom_id: mushroom.id
        }
      }
    end
    assert_redirected_to cluster_mushroom_path(ClusterMushroom.last)
  end

  test "should show cluster_mushroom" do
    get cluster_mushroom_path(@cluster_mushroom)
    assert_response :success
  end

  test "should get edit" do
    get edit_cluster_mushroom_path(@cluster_mushroom)
    assert_response :success
  end

  test "should update cluster mushroom" do
    # Update params should match existing cluster_mushroom or use valid ones
    patch cluster_mushroom_path(@cluster_mushroom), params: {
      cluster_mushroom: {
        cluster_id: @cluster_mushroom.cluster_id,
        mushroom_id: @cluster_mushroom.mushroom_id
      }
    }
    assert_redirected_to cluster_mushroom_path(@cluster_mushroom)
  end


  test "should destroy cluster_mushroom" do
    assert_difference("ClusterMushroom.count", -1) do
      delete cluster_mushroom_path(@cluster_mushroom)
    end

    assert_redirected_to mushrooms_path
  end
end


