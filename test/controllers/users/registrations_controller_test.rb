require "test_helper"

class Users::RegistrationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
  end

  test "should get new registration" do
    get new_user_registration_url
    assert_response :success
  end

  test "should create user with valid params" do
    assert_difference("User.count") do
      post user_registration_url, params: {
        user: {
          email: "newuser@example.com",
          password: "password123",
          password_confirmation: "password123",
          display_name: "New User"
        }
      }
    end

    assert_redirected_to root_path
  end

  test "should reject registration with honeypot filled" do
    assert_no_difference("User.count") do
      post user_registration_url, params: {
        user: {
          email: "bot@example.com",
          password: "password123",
          password_confirmation: "password123",
          website_url: "http://spam.com"  # Honeypot
        }
      }
    end

    assert_redirected_to new_user_registration_path
    assert_equal "Registration failed. Please try again.", flash[:alert]
  end

  test "should get edit registration" do
    sign_in @user
    get edit_user_registration_url
    assert_response :success
  end

  test "should update user without password" do
    sign_in @user

    patch user_registration_url, params: {
      user: {
        display_name: "Updated Name",
        email: @user.email
      }
    }

    assert_redirected_to authenticated_root_path
    @user.reload
    assert_equal "Updated Name", @user.display_name
  end

  test "should update user with password" do
    sign_in @user

    patch user_registration_url, params: {
      user: {
        current_password: "password",
        password: "newpassword123",
        password_confirmation: "newpassword123",
        email: @user.email
      }
    }

    assert_redirected_to authenticated_root_path
  end

  test "should destroy user account" do
    sign_in @user
    # Delete dependent records that would prevent user deletion
    AdminTodo.where(user_id: @user.id).delete_all if defined?(AdminTodo)

    assert_difference("User.count", -1) do
      delete user_registration_url
    end

    assert_redirected_to root_path
  end

  test "should handle strict_loading on destroy" do
    sign_in @user
    # Delete dependent records that would prevent user deletion
    AdminTodo.where(user_id: @user.id).delete_all if defined?(AdminTodo)

    # Verify strict_loading is disabled during destroy
    delete user_registration_url
    assert_redirected_to root_path
  end

  test "should reject invalid registration" do
    assert_no_difference("User.count") do
      post user_registration_url, params: {
        user: {
          email: "",  # Invalid
          password: "password123"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "guest should access new registration" do
    get new_user_registration_url
    assert_response :success
  end

  test "guest should not access edit registration" do
    get edit_user_registration_url
    assert_redirected_to new_user_session_path
  end
end
