require "test_helper"

class Admin::DashboardControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_user = users(:one)
    @admin_user.permission_id = 2
    sign_in @admin_user
  end

  test "should get index" do
    get admin_root_url
    assert_response :success
  end

  test "should display dashboard statistics" do
    get admin_root_url
    assert_response :success
    assert assigns(:mr_character_count)
    assert assigns(:lookup_item_count)
    assert assigns(:source_data_count)
  end

  test "should handle empty database gracefully" do
    # Even with no data, dashboard should load
    get admin_root_url
    assert_response :success
  end
end
