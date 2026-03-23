require "application_system_test_case"

class AdminDashboardTest < ApplicationSystemTestCase
  setup do
    @admin_user = users(:one)
    @admin_user.update!(permission_id: 1, confirmed_at: Time.current)

    @regular_user = users(:two)
    @regular_user.update!(permission_id: 9, confirmed_at: Time.current)
  end

  test "admin can access dashboard and core admin links" do
    sign_in @admin_user
    visit admin_root_path

    assert_selector "h1", text: /Awareness Admin Dashboard/i
    assert_link "Users"
    assert_link "Articles"
    assert_link "Newsletter Campaigns"
    assert_link "Subjects"
    assert_link "References"
  end

  test "dashboard does not show removed legacy links" do
    sign_in @admin_user
    visit admin_root_path

    assert_no_link "Colors"
    assert_no_link "Countries"
    assert_no_link "States"
    assert_no_link "Fungus Types"
    assert_no_link "Genus"
    assert_no_link "Species"
    assert_no_link "Source Data"
    assert_no_link "Download Database Backup Options"
  end

  test "non-admin is redirected out of admin" do
    sign_in @regular_user
    visit admin_root_path

    assert_current_path root_path
  end
end
