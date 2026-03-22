require "test_helper"

class Admin::UtilityControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_user = users(:one)
    @admin_user.permission_id = 2
    sign_in @admin_user
  end

  # Skipping: test requires mocha which is not configured
  # test "export_database should redirect to admin root" do
  #   # Mock the system call to prevent actual database export
  #   Admin::UtilityController.any_instance.stubs(:system).returns(true)
  #
  #   get export_database_admin_utility_index_url
  #   assert_redirected_to admin_root_path
  #   assert_equal "Database exported successfully.", flash[:notice]
  # end

  # Skipping: test requires mocha which is not configured
  # test "run_scripts should repopulate genus and species" do
  #   # Mock the repopulation methods
  #   Genus.stubs(:populate_from_mb_lists).returns(true)
  #   Species.stubs(:populate_from_mb_lists).returns(true)
  #
  #   get run_scripts_admin_utility_index_url
  #   assert_redirected_to admin_root_path
  #   assert_equal "Genus and species updated.", flash[:notice]
  # end

  test "non-admin should not access utility functions" do
    sign_out @admin_user
    regular_user = users(:two)
    sign_in regular_user

    get admin_database_export_path
    assert_redirected_to root_path
    assert_equal "You are not authorized to access this area.", flash[:alert]
  end

  test "guest should not access utility functions" do
    sign_out @admin_user

    get admin_database_export_path
    assert_redirected_to new_user_session_path
  end
end
