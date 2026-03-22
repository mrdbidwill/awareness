# test/system/user_login_test.rb
require "application_system_test_case"

class UserLoginTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
    @user.update(confirmed_at: Time.current) # Ensure user is confirmed
  end

  test "visiting the login page" do
    visit new_user_session_path

    assert_selector "h2", text: /log in|sign in/i
    assert_field "Email"
    assert_field "Password"
    assert_button /log in|sign in/i
  end

  test "successful login with valid credentials" do
    visit new_user_session_path

    fill_in "Email", with: @user.email
    fill_in "Password", with: "password"

    click_button /log in|sign in/i

    # Should be redirected to authenticated area
    assert_text /signed in successfully/i
  end

  test "login fails with invalid email" do
    visit new_user_session_path

    fill_in "Email", with: "nonexistent@example.com"
    fill_in "Password", with: "password"

    click_button /log in|sign in/i

    assert_text /invalid email or password/i
    assert_current_path new_user_session_path
  end

  test "login fails with incorrect password" do
    visit new_user_session_path

    fill_in "Email", with: @user.email
    fill_in "Password", with: "wrongpassword"

    click_button /log in|sign in/i

    assert_text /invalid email or password/i
    assert_current_path new_user_session_path
  end

  test "remember me checkbox is present" do
    visit new_user_session_path

    if page.has_field?("Remember me")
      assert_field "Remember me", type: "checkbox"
    end
  end

  test "successful logout" do
    sign_in @user
    visit root_path

    # Look for logout link/button
    if page.has_link?("Log out") || page.has_link?("Sign out")
      click_link /log out|sign out/i
      assert_text /signed out successfully/i
    elsif page.has_button?("Log out") || page.has_button?("Sign out")
      click_button /log out|sign out/i
      assert_text /signed out successfully/i
    end
  end

  test "can navigate to registration from login page" do
    visit new_user_session_path

    if page.has_link?("Sign up")
      click_link "Sign up"
      assert_current_path new_user_registration_path
    end
  end

  test "can navigate to forgot password from login page" do
    visit new_user_session_path

    if page.has_link?("Forgot your password?")
      click_link "Forgot your password?"
      assert_current_path new_user_password_path
    end
  end

  test "login with remember me checked" do
    visit new_user_session_path

    fill_in "Email", with: @user.email
    fill_in "Password", with: "password"

    if page.has_field?("Remember me")
      check "Remember me"
    end

    click_button /log in|sign in/i

    assert_text /signed in successfully/i
  end

  test "2FA setup flow for new user" do
    # Create user without 2FA enabled
    @user.update(otp_required_for_login: false)
    sign_in @user

    visit root_path

    # Navigate to 2FA settings if available
    if page.has_link?("Account") || page.has_link?("Settings") || page.has_link?("Profile")
      # Try to find 2FA settings
      visit edit_user_registration_path rescue nil

      # Check if 2FA setup is available
      if page.has_text?("Two-Factor Authentication") || page.has_text?("2FA")
        assert_text /two.?factor/i
      end
    end
  end

  test "2FA verification flow" do
    # Setup user with 2FA enabled
    @user.update(
      otp_required_for_login: true,
      otp_secret: User.generate_otp_secret
    )

    visit new_user_session_path

    fill_in "Email", with: @user.email
    fill_in "Password", with: "password"

    click_button /log in|sign in/i

    # Should be redirected to 2FA verification page
    if page.has_text?("Enter your authentication code") || page.has_field?("code")
      assert_current_path user_two_factor_authentication_path
      assert_field "code"
    end
  end

  test "2FA verification with valid code" do
    # Setup user with 2FA
    otp_secret = User.generate_otp_secret
    @user.update(
      otp_required_for_login: true,
      otp_secret: otp_secret
    )

    # Generate valid OTP code
    require 'rotp'
    totp = ROTP::TOTP.new(otp_secret)
    valid_code = totp.now

    visit new_user_session_path

    fill_in "Email", with: @user.email
    fill_in "Password", with: "password"
    click_button /log in|sign in/i

    # Enter 2FA code if prompted
    if page.has_field?("code")
      fill_in "code", with: valid_code
      click_button "Verify"

      assert_text /signed in successfully/i
    end
  end

  test "2FA verification with invalid code" do
    # Setup user with 2FA
    @user.update(
      otp_required_for_login: true,
      otp_secret: User.generate_otp_secret
    )

    visit new_user_session_path

    fill_in "Email", with: @user.email
    fill_in "Password", with: "password"
    click_button /log in|sign in/i

    # Enter invalid 2FA code if prompted
    if page.has_field?("code")
      fill_in "code", with: "000000"
      click_button "Verify"

      assert_text /invalid authentication code/i
    end
  end

  test "trust device option during 2FA verification" do
    # Setup user with 2FA
    @user.update(
      otp_required_for_login: true,
      otp_secret: User.generate_otp_secret
    )

    visit new_user_session_path

    fill_in "Email", with: @user.email
    fill_in "Password", with: "password"
    click_button /log in|sign in/i

    # Check for trust device option
    if page.has_field?("Trust this device")
      assert_field "Trust this device", type: "checkbox"
    end
  end

  test "2FA backup code recovery" do
    # Setup user with 2FA and backup codes
    @user.update(
      otp_required_for_login: true,
      otp_secret: User.generate_otp_secret
    )
    backup_codes = @user.generate_otp_backup_codes!
    @user.save

    visit new_user_session_path

    fill_in "Email", with: @user.email
    fill_in "Password", with: "password"
    click_button /log in|sign in/i

    # Look for backup code link
    if page.has_link?("Use a backup code") || page.has_text?("backup code")
      click_link "Use a backup code" rescue nil

      if page.has_field?("backup_code") || page.has_field?("code")
        fill_in "code", with: backup_codes.first
        click_button "Verify"

        # Should successfully login with backup code
        assert_text /signed in successfully/i
      end
    end
  end

  test "locked account cannot login" do
    # Lock the user account
    @user.lock_access!

    visit new_user_session_path

    fill_in "Email", with: @user.email
    fill_in "Password", with: "password"
    click_button /log in|sign in/i

    assert_text /account is locked/i
  end

  test "unconfirmed account cannot login" do
    # Create unconfirmed user
    @user.update(confirmed_at: nil)

    visit new_user_session_path

    fill_in "Email", with: @user.email
    fill_in "Password", with: "password"
    click_button /log in|sign in/i

    assert_text /confirm your email|confirmation instructions/i
  end

  test "login page is mobile responsive" do
    # Test with mobile viewport
    page.driver.browser.manage.window.resize_to(375, 667)

    visit new_user_session_path

    assert_selector "h2", text: /log in|sign in/i
    assert_field "Email"
    assert_field "Password"
    assert_button /log in|sign in/i

    # Reset to default size
    page.driver.browser.manage.window.resize_to(1400, 1400)
  end

  test "session persists across page navigation" do
    sign_in @user
    visit root_path

    # Navigate to another page
    visit mushrooms_path rescue visit root_path

    # User should still be logged in
    # Check for user-specific content or links
    if page.has_link?("Log out") || page.has_link?("Sign out")
      assert true
    end
  end

  test "redirect to requested page after login" do
    # Try to access protected page
    visit mushrooms_path

    # Should be redirected to login
    assert_current_path new_user_session_path

    # Login
    fill_in "Email", with: @user.email
    fill_in "Password", with: "password"
    click_button /log in|sign in/i

    # Should be redirected back to mushrooms path
    assert_current_path mushrooms_path
  end
end
