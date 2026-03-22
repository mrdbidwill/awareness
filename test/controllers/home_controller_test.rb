require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get root_url
    assert_response :success
  end

  test "should get index without authentication" do
    get root_url
    assert_response :success
  end

  test "authenticated user should see home page" do
    sign_in users(:one)
    get root_url
    assert_response :success
  end
end
