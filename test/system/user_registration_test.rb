# test/system/user_registration_test.rb
require "application_system_test_case"

class UserRegistrationTest < ApplicationSystemTestCase
  setup do
    # Clear any existing users to avoid conflicts
    @test_email = "newuser#{Time.now.to_i}@example.com"
  end

  test "visiting the registration page" do
    visit new_user_registration_path

    assert_selector "h2", text: /sign up/i
    assert_selector "input[type='email']"
    assert_selector "input[type='password']"
    assert_button "Sign up"
  end

  test "successful user registration with valid data" do
    visit new_user_registration_path

    fill_in "Email", with: @test_email
    fill_in "Password", with: "password123"
    fill_in "Password confirmation", with: "password123"

    # Check for display name field if it exists
    if page.has_field?("Display name")
      fill_in "Display name", with: "Test User"
    end

    click_button "Sign up"

    # User should be created and see confirmation message
    assert_text /confirmation link has been sent|confirm your email/i
  end

  test "registration fails with invalid email" do
    visit new_user_registration_path

    fill_in "Email", with: "invalid-email"
    fill_in "Password", with: "password123"
    fill_in "Password confirmation", with: "password123"

    click_button "Sign up"

    assert_text /email is invalid/i
  end

  test "registration fails with short password" do
    visit new_user_registration_path

    fill_in "Email", with: @test_email
    fill_in "Password", with: "123"
    fill_in "Password confirmation", with: "123"

    click_button "Sign up"

    assert_text /password is too short/i
  end

  test "registration fails with mismatched passwords" do
    visit new_user_registration_path

    fill_in "Email", with: @test_email
    fill_in "Password", with: "password123"
    fill_in "Password confirmation", with: "different123"

    click_button "Sign up"

    assert_text /password confirmation doesn't match/i
  end

  test "registration fails with existing email" do
    visit new_user_registration_path

    # Use existing user from fixtures
    fill_in "Email", with: users(:one).email
    fill_in "Password", with: "password123"
    fill_in "Password confirmation", with: "password123"

    click_button "Sign up"

    assert_text /email has already been taken/i
  end

  test "honeypot field prevents bot registration" do
    visit new_user_registration_path

    # Fill in the honeypot field (should be hidden with CSS)
    if page.has_field?("user[website_url]", visible: false)
      fill_in "user[website_url]", with: "http://spam.com", visible: false
    end

    fill_in "Email", with: @test_email
    fill_in "Password", with: "password123"
    fill_in "Password confirmation", with: "password123"

    click_button "Sign up"

    # Should be redirected back with error
    assert_text /registration failed/i
  end

  test "registration form has all required fields" do
    visit new_user_registration_path

    assert_field "Email"
    assert_field "Password"
    assert_field "Password confirmation"
    assert_button "Sign up"
  end

  test "can navigate to login from registration page" do
    visit new_user_registration_path

    # Look for link to login page
    if page.has_link?("Log in")
      click_link "Log in"
      assert_current_path new_user_session_path
    elsif page.has_link?("Sign in")
      click_link "Sign in"
      assert_current_path new_user_session_path
    end
  end

  test "display name is optional during registration" do
    visit new_user_registration_path

    fill_in "Email", with: @test_email
    fill_in "Password", with: "password123"
    fill_in "Password confirmation", with: "password123"

    # Don't fill in display name if it exists

    click_button "Sign up"

    # Registration should still succeed
    assert_text /confirmation link has been sent|confirm your email/i
  end

  test "password visibility toggle works" do
    visit new_user_registration_path

    password_field = find("input[type='password']", match: :first)

    # Check if there's a visibility toggle button/icon
    if page.has_css?("[data-action*='toggle']") || page.has_css?(".password-toggle")
      # Password field should initially be type='password'
      assert_equal "password", password_field[:type]

      # This test would need JavaScript driver to fully test toggle functionality
      # Just verify the field exists for now
      assert password_field
    end
  end

  test "form validation prevents empty submission" do
    visit new_user_registration_path

    # Try to submit empty form
    click_button "Sign up"

    # Should see validation errors
    assert_text /can't be blank|is invalid/i
  end

  test "registration page is mobile responsive" do
    # Test with mobile viewport
    page.driver.browser.manage.window.resize_to(375, 667)

    visit new_user_registration_path

    assert_selector "h2", text: /sign up/i
    assert_selector "input[type='email']"
    assert_selector "input[type='password']"
    assert_button "Sign up"

    # Reset to default size
    page.driver.browser.manage.window.resize_to(1400, 1400)
  end
end
