require "test_helper"
require "rack/mock"

class Users::SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @user.update!(otp_required_for_login: false)
  end

  test "should get new session" do
    get new_user_session_url
    assert_response :success
  end

  test "should create session with valid credentials" do
    post user_session_url, params: {
      user: {
        email: @user.email,
        password: "password"
      }
    }

    assert_redirected_to authenticated_root_path
  end

  test "should redirect to 2FA when enabled" do
    @user.update!(
      otp_required_for_login: true,
      otp_secret: User.generate_otp_secret
    )

    post user_session_url, params: {
      user: {
        email: @user.email,
        password: "password"
      }
    }

    assert_redirected_to user_two_factor_authentication_path
    assert session[:otp_user_id]
  end

  test "should skip 2FA with trusted device" do
    @user.update!(
      otp_required_for_login: true,
      otp_secret: User.generate_otp_secret
    )

    user_agent = "RSpec Trusted Device"
    remote_ip = "203.0.113.10"
    fingerprint = Digest::SHA256.hexdigest("#{user_agent}-#{remote_ip}")

    trusted_device = @user.trusted_devices.create!(device_fingerprint: fingerprint)
    encrypted_token = encrypted_cookie_value(:trusted_device_token, trusted_device.device_token)
    cookies[:trusted_device_token] = encrypted_token

    post user_session_url, params: {
      user: {
        email: @user.email,
        password: "password"
      }
    }, headers: { "User-Agent" => user_agent, "REMOTE_ADDR" => remote_ip }

    # Should sign in directly without 2FA
    assert_redirected_to authenticated_root_path
    assert_nil session[:otp_user_id]
  end

  test "should clear invalid trusted device cookie" do
    @user.update!(
      otp_required_for_login: true,
      otp_secret: User.generate_otp_secret
    )

    # Set invalid cookie
    cookies[:trusted_device_token] = "invalid_token"

    post user_session_url, params: {
      user: {
        email: @user.email,
        password: "password"
      }
    }

    assert_redirected_to user_two_factor_authentication_path
  end

  test "should reject invalid credentials" do
    post user_session_url, params: {
      user: {
        email: @user.email,
        password: "wrongpassword"
      }
    }

    assert_response :unprocessable_entity
  end

  test "should destroy session" do
    sign_in @user

    delete destroy_user_session_url
    assert_redirected_to root_path
  end

  test "guest should access new session" do
    get new_user_session_url
    assert_response :success
  end

  private

  def encrypted_cookie_value(key, value)
    config = Rails.application.config.action_dispatch
    secret_key_base = Rails.application.secret_key_base || "test-secret-key-base"
    key_generator = ActiveSupport::KeyGenerator.new(secret_key_base, iterations: 1000)

    serializer = case config.cookies_serializer
                 when nil
                   ActiveSupport::Messages::SerializerWithFallback[:marshal]
                 when :hybrid
                   ActiveSupport::Messages::SerializerWithFallback[:json_allow_marshal]
                 when Symbol
                   ActiveSupport::Messages::SerializerWithFallback[config.cookies_serializer]
                 else
                   config.cookies_serializer
                 end

    serialized_value = serializer.dump(value)

    if config.use_authenticated_cookie_encryption
      cipher = config.encrypted_cookie_cipher || "aes-256-gcm"
      key_len = ActiveSupport::MessageEncryptor.key_len(cipher)
      secret = key_generator.generate_key(config.authenticated_encrypted_cookie_salt, key_len)
      encryptor = ActiveSupport::MessageEncryptor.new(
        secret,
        cipher: cipher,
        serializer: ActiveSupport::MessageEncryptor::NullSerializer
      )
    else
      key_len = ActiveSupport::MessageEncryptor.key_len("aes-256-cbc")
      secret = key_generator.generate_key(config.encrypted_cookie_salt, key_len)
      sign_secret = key_generator.generate_key(config.encrypted_signed_cookie_salt)
      encryptor = ActiveSupport::MessageEncryptor.new(
        secret,
        sign_secret,
        cipher: "aes-256-cbc",
        serializer: ActiveSupport::MessageEncryptor::NullSerializer
      )
    end

    metadata = {}
    metadata[:purpose] = "cookie.#{key}" if config.use_cookies_with_metadata
    encryptor.encrypt_and_sign(serialized_value, **metadata)
  end
end
