require "test_helper"

class Admin::DashboardControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_user = users(:one)
    @admin_user.update!(permission_id: 1, confirmed_at: Time.current)
    sign_in @admin_user
  end

  test "index loads" do
    get admin_root_url
    assert_response :success
  end

  test "dashboard shows core editorial stats" do
    get admin_root_url
    assert_response :success

    assert_includes response.body, "Published Articles"
    assert_includes response.body, "Newsletter Subscribers"
    assert_includes response.body, "Subjects"
    assert_includes response.body, "Sources"
  end
end
