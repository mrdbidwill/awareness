require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    # User must be admin (permission_id = 1) to access users controller
    @user.update!(permission_id: 1)
    sign_in @user
  end

  test "should get index" do
    get admin_users_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_user_url
    assert_response :success
  end

  # TODO: User creation should go through Devise registration, not UsersController
  # Custom admin user management needs different approach or use Devise admin gems

  test "should show user" do
    get admin_user_url(@user)
    assert_response :success
  end

  test "should return 404 for non-existent user" do
    get admin_user_url(id: 99999)
    assert_response :not_found
  end

  test "should get edit" do
    get edit_admin_user_url(@user)
    assert_response :success
  end

  test "should update user" do
    patch admin_user_url(@user), params: {
      user: {
        display_name: "Updated Name"
      }
    }

    assert_redirected_to admin_user_url(@user)
    assert_equal "User was successfully updated.", flash[:notice]
  end

  test "should destroy user" do
    user_to_delete = User.create!(
      email: "delete@example.com",
      password: "password123456",
      password_confirmation: "password123456"
    )

    assert_difference("User.count", -1) do
      delete admin_user_url(user_to_delete)
    end

    assert_redirected_to admin_users_url
    assert_equal "User was successfully deleted.", flash[:notice]
  end

  test "should handle invalid creation" do
    assert_no_difference("User.count") do
      post admin_users_url, params: {
        user: {
          email: "",  # Invalid
          password: "password"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should handle invalid update" do
    patch admin_user_url(@user), params: {
      user: {
        email: ""  # Invalid
      }
    }

    assert_response :unprocessable_entity
  end

  test "should require authentication" do
    sign_out @user

    get admin_users_url
    assert_redirected_to new_user_session_path
  end
end
