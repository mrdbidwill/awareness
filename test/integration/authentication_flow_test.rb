require "test_helper"

class AuthenticationFlowTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:two)
    @user.update!(confirmed_at: Time.current, permission_id: 9)

    @admin_user = users(:one)
    @admin_user.update!(confirmed_at: Time.current, permission_id: 1)
  end

  test "user can register with valid information" do
    assert_difference("User.count", 1) do
      post user_registration_path, params: {
        user: {
          email: "newuser@example.com",
          display_name: "New User",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    assert_redirected_to root_path
  end

  test "user cannot register with invalid email" do
    assert_no_difference("User.count") do
      post user_registration_path, params: {
        user: {
          email: "invalid_email",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "honeypot field blocks registration" do
    assert_no_difference("User.count") do
      post user_registration_path, params: {
        user: {
          email: "spammer@example.com",
          password: "password123",
          password_confirmation: "password123",
          website_url: "https://spam.invalid"
        }
      }
    end

    assert_redirected_to new_user_registration_path
  end

  test "confirmed user can login" do
    post user_session_path, params: {
      user: {
        email: @user.email,
        password: "password"
      }
    }

    assert_redirected_to authenticated_root_path
  end

  test "user cannot login with invalid password" do
    post user_session_path, params: {
      user: {
        email: @user.email,
        password: "wrong_password"
      }
    }

    assert_response :unprocessable_entity
  end

  test "authenticated user can logout" do
    sign_in @user

    delete destroy_user_session_path

    assert_redirected_to root_path
  end

  test "non admin user cannot access admin area" do
    sign_in @user

    get admin_root_path

    assert_redirected_to root_path
    assert_equal "You are not authorized to access this area.", flash[:alert]
  end

  test "admin user can access admin area" do
    sign_in @admin_user

    get admin_root_path

    assert_response :success
  end

  test "user can request password reset" do
    post user_password_path, params: {
      user: {
        email: @user.email
      }
    }

    assert_redirected_to new_user_session_path
    assert_not_nil @user.reload.reset_password_token
  end

  test "user can enable 2fa" do
    sign_in @user

    post enable_users_two_factor_settings_path

    assert_redirected_to edit_user_registration_path
    assert @user.reload.otp_secret.present?
  end
end
