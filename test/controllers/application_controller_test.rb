require "test_helper"

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
  end

  test "public root page renders successfully" do
    get root_url
    assert_response :success
  end

  test "authenticated root page renders successfully" do
    sign_in @user
    get authenticated_root_path
    assert_response :success
  end

  test "application controller still configures devise params hook" do
    assert ApplicationController.method_defined?(:configure_permitted_parameters, false)
  end

  test "application controller defines after_sign_in_path hook" do
    assert ApplicationController.method_defined?(:after_sign_in_path_for)
  end
end
