require "test_helper"

class Users::TwoFactorAuthenticationControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @user.update!(
      otp_required_for_login: true,
      otp_secret: User.generate_otp_secret
    )
  end

  test "should show 2FA form with valid session" do
    # Simulate what the sessions controller does: set otp_user_id in session
    post user_session_url, params: {
      user: {
        email: @user.email,
        password: "password"
      }
    }
    # At this point, session[:otp_user_id] should be set by the sessions controller

    get user_two_factor_authentication_url

    assert_response :success
    assert assigns(:user)
  end

  test "should redirect to login without otp_user_id" do
    get user_two_factor_authentication_url
    assert_redirected_to new_user_session_path
    assert_equal "Please log in first.", flash[:alert]
  end

  test "should verify valid OTP code" do
    otp_code = @user.current_otp

    # Login to set session[:otp_user_id]
    post user_session_url, params: {
      user: {
        email: @user.email,
        password: "password"
      }
    }

    patch user_two_factor_authentication_url,
      params: { otp_attempt: otp_code }

    assert_redirected_to authenticated_root_path
    assert_nil session[:otp_user_id]
    assert_equal "Successfully signed in with 2FA", flash[:notice]
  end

  test "should reject invalid OTP code" do
    # Login to set session[:otp_user_id]
    post user_session_url, params: {
      user: {
        email: @user.email,
        password: "password"
      }
    }

    patch user_two_factor_authentication_url,
      params: { otp_attempt: "000000" }  # Invalid code

    assert_response :success
    assert_template :show
    assert_equal "Invalid OTP code. Please try again.", flash[:alert]
  end

  test "should create trusted device when requested" do
    otp_code = @user.current_otp

    # Login to set session[:otp_user_id]
    post user_session_url, params: {
      user: {
        email: @user.email,
        password: "password"
      }
    }

    assert_difference("@user.trusted_devices.count") do
      patch user_two_factor_authentication_url,
        params: { otp_attempt: otp_code, trust_device: "1" }
    end

    assert_redirected_to authenticated_root_path
    assert cookies[:trusted_device_token].present?
  end

  test "should not create trusted device when not requested" do
    otp_code = @user.current_otp

    # Login to set session[:otp_user_id]
    post user_session_url, params: {
      user: {
        email: @user.email,
        password: "password"
      }
    }

    assert_no_difference("@user.trusted_devices.count") do
      patch user_two_factor_authentication_url,
        params: { otp_attempt: otp_code, trust_device: "0" }
    end

    assert_redirected_to authenticated_root_path
  end

  # Skipping: test requires mocha which is not configured
  # test "should set secure cookie in production" do
  #   Rails.env.stubs(:production?).returns(true)
  #   request.session[:otp_user_id] = @user.id
  #   otp_code = @user.current_otp
  #
  #   patch user_two_factor_authentication_url, params: {
  #     otp_attempt: otp_code,
  #     trust_device: "1"
  #   }
  #
  #   assert_redirected_to authenticated_root_path
  # end

  test "should clear otp_user_id on successful verification" do
    otp_code = @user.current_otp

    # Login to set session[:otp_user_id]
    post user_session_url, params: {
      user: {
        email: @user.email,
        password: "password"
      }
    }

    patch user_two_factor_authentication_url,
      params: { otp_attempt: otp_code }

    assert_nil session[:otp_user_id]
  end

  test "should redirect to after_sign_in_path" do
    otp_code = @user.current_otp

    # Login to set session[:otp_user_id]
    post user_session_url, params: {
      user: {
        email: @user.email,
        password: "password"
      }
    }

    patch user_two_factor_authentication_url,
      params: { otp_attempt: otp_code }

    assert_redirected_to authenticated_root_path
  end
end
