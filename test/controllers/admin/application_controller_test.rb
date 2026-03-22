require "test_helper"

class Admin::ApplicationControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_user = users(:one)
    @admin_user.permission_id = 2
    @regular_user = users(:two)
  end

  test "admin user should access admin namespace" do
    sign_in @admin_user
    # Testing with a specific admin controller action that exists
    get admin_countries_url
    assert_response :success
  end

  test "regular user should not access admin namespace" do
    sign_in @regular_user
    # Attempt to access admin area
    get admin_countries_url
    assert_redirected_to root_path
    assert_equal "You are not authorized to access this area.", flash[:alert]
  end

  test "guest user should be redirected to sign in" do
    get admin_countries_url
    assert_redirected_to new_user_session_path
  end
end
