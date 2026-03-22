require "test_helper"

class AllGroupMushroomsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @all_group_mushroom = all_group_mushrooms(:one)

    # Sign in user for authentication
    @user = users(:one)
    @user.permission_id = 2
    sign_in @user
  end

  test "should get index" do
    get all_group_mushrooms_path
    assert_response :success
  end

  test "should get new" do
    get '/all_group_mushrooms/new'
    assert_response :success
  end

  test "should create Group" do
    # Use all_groups(:two) with mushrooms(:one) to avoid duplicate
    assert_difference("AllGroupMushroom.count", 1) do
      post all_group_mushrooms_path, params: {
        all_group_mushroom: {
          all_group_id: all_groups(:two).id,
          mushroom_id: mushrooms(:one).id
        }
      }
    end
    assert_redirected_to all_group_mushroom_path(AllGroupMushroom.last)
  end

  test "should show all_group_mushroom" do
    get all_group_mushroom_path(@all_group_mushroom)
    assert_response :success
  end

  test "should get edit" do
    get edit_all_group_mushroom_path(@all_group_mushroom)
    assert_response :success
  end

  test "should update all_group mushroom" do
    # Keep same IDs as existing record to avoid uniqueness violation
    patch all_group_mushroom_path(@all_group_mushroom), params: {
      all_group_mushroom: {
        all_group_id: @all_group_mushroom.all_group_id,
        mushroom_id: @all_group_mushroom.mushroom_id
      }
    }
    assert_redirected_to all_group_mushroom_path(@all_group_mushroom)
  end


  test "should destroy all_group_mushroom" do
    assert_difference("AllGroupMushroom.count", -1) do
      delete all_group_mushroom_path(@all_group_mushroom)
    end

    assert_redirected_to mushrooms_path
  end
end


