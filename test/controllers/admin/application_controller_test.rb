require "test_helper"

class Admin::ApplicationControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_user = users(:one)
    @admin_user.update!(permission_id: 1)
    @regular_user = users(:two)
    @regular_user.update!(permission_id: 9)
  end

  test "admin user can access admin dashboard" do
    sign_in @admin_user

    get admin_root_path

    assert_response :success
  end

  test "regular user is blocked from admin namespace" do
    sign_in @regular_user

    get admin_root_path

    assert_redirected_to root_path
    assert_equal "You are not authorized to access this area.", flash[:alert]
  end

  test "guest user is redirected to sign in" do
    get admin_root_path

    assert_redirected_to new_user_session_path
  end
end
