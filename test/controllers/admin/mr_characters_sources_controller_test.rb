require "test_helper"

class Admin::MrCharactersSourcesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_user = users(:one)
    @admin_user.permission_id = 2
    sign_in @admin_user

    # Create a test CSV file
    csv_path = Rails.root.join("public", "docs", "mr_characters_source.csv")
    FileUtils.mkdir_p(File.dirname(csv_path))
    File.write(csv_path, "id,name,description\n1,Test Character,Test Description\n")
  end

  teardown do
    # Clean up test CSV
    csv_path = Rails.root.join("public", "docs", "mr_characters_source.csv")
    File.delete(csv_path) if File.exist?(csv_path)
  end

  test "should show csv content" do
    get admin_mr_characters_source_url
    assert_response :success
    assert assigns(:headers)
    assert assigns(:rows)
  end

  test "should handle missing csv file" do
    File.delete(Rails.root.join("public", "docs", "mr_characters_source.csv"))

    get admin_mr_characters_source_url
    assert_redirected_to root_path
    assert_match /Source CSV not found/, flash[:alert]
  end

  test "non-admin should not access" do
    sign_out @admin_user
    regular_user = users(:two)
    sign_in regular_user

    get admin_mr_characters_source_url
    assert_redirected_to root_path
    assert_equal "You are not authorized to access this area.", flash[:alert]
  end

  test "guest should not access" do
    sign_out @admin_user

    get admin_mr_characters_source_url
    assert_redirected_to root_path
  end
end
