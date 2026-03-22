require "test_helper"

class Users::TwoFactorSettingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @user.update!(otp_required_for_login: false)
    sign_in @user
  end

  test "should enable 2FA" do
    post enable_users_two_factor_settings_url

    assert_redirected_to edit_user_registration_path
    assert_equal "Scan the QR code and enter a verification code to enable 2FA.", flash[:notice]
    assert session[:enabling_otp]

    @user.reload
    assert @user.otp_secret.present?
  end

  test "should not enable 2FA if already enabled" do
    @user.update!(otp_required_for_login: true)

    post enable_users_two_factor_settings_url

    assert_redirected_to edit_user_registration_path
    assert_equal "2FA is already enabled.", flash[:alert]
  end

  test "should verify OTP and complete 2FA setup" do
    @user.otp_secret = User.generate_otp_secret
    @user.save!

    # Set session by making initial request
    post enable_users_two_factor_settings_url

    otp_code = @user.current_otp

    post verify_users_two_factor_settings_url, params: {
      otp_attempt: otp_code
    }

    assert_redirected_to edit_user_registration_path
    assert_match /2FA has been enabled successfully/, flash[:notice]
    assert_nil session[:enabling_otp]

    @user.reload
    assert @user.otp_required_for_login
    assert @user.otp_backup_codes.any?
  end

  test "should reject invalid OTP during verification" do
    @user.otp_secret = User.generate_otp_secret
    @user.save!

    # Set session by making initial request
    post enable_users_two_factor_settings_url

    post verify_users_two_factor_settings_url, params: {
      otp_attempt: "000000"  # Invalid
    }

    assert_redirected_to edit_user_registration_path
    assert_equal "Invalid verification code. Please try again.", flash[:alert]

    @user.reload
    assert_not @user.otp_required_for_login
  end

  test "should require OTP code for verification" do
    post verify_users_two_factor_settings_url, params: {
      otp_attempt: ""
    }

    assert_redirected_to edit_user_registration_path
    assert_equal "Please enter the verification code.", flash[:alert]
  end

  test "should disable 2FA with valid password" do
    @user.update!(
      otp_required_for_login: true,
      otp_secret: User.generate_otp_secret,
      otp_backup_codes: ["code1", "code2"]
    )

    delete disable_users_two_factor_settings_url, params: {
      current_password: "password"
    }

    assert_redirected_to edit_user_registration_path
    assert_equal "2FA has been disabled.", flash[:notice]

    @user.reload
    assert_not @user.otp_required_for_login
    assert_empty @user.otp_backup_codes
  end

  test "should not disable 2FA with invalid password" do
    @user.update!(
      otp_required_for_login: true,
      otp_secret: User.generate_otp_secret
    )

    delete disable_users_two_factor_settings_url, params: {
      current_password: "wrongpassword"
    }

    assert_redirected_to edit_user_registration_path
    assert_equal "Invalid password. Cannot disable 2FA.", flash[:alert]

    @user.reload
    assert @user.otp_required_for_login
  end

  test "should generate backup codes on verification" do
    @user.otp_secret = User.generate_otp_secret
    @user.save!

    # Set session by making initial request
    post enable_users_two_factor_settings_url

    otp_code = @user.current_otp

    post verify_users_two_factor_settings_url, params: {
      otp_attempt: otp_code
    }

    assert flash[:backup_codes].present?
    assert flash[:backup_codes].is_a?(Array)
  end

  # Skipping: test requires mocha which is not configured
  # test "should handle enable errors gracefully" do
  #   User.any_instance.stubs(:save).returns(false)
  #   User.any_instance.stubs(:errors).returns(
  #     ActiveModel::Errors.new(User.new).tap { |e| e.add(:base, "Error") }
  #   )
  #
  #   get enable_users_two_factor_settings_url
  #
  #   assert_redirected_to edit_user_registration_path
  #   assert_match /Failed to enable 2FA/, flash[:alert]
  # end

  test "should require authentication" do
    sign_out @user

    post enable_users_two_factor_settings_url
    assert_redirected_to new_user_session_path
  end

  test "should clear enabling_otp session on disable" do
    @user.update!(otp_required_for_login: true)

    # Set session by enabling first
    post enable_users_two_factor_settings_url

    delete disable_users_two_factor_settings_url, params: {
      current_password: "password"
    }

    assert_nil session[:enabling_otp]
  end
end
