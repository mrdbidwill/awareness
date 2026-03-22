require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "should get home without authentication" do
    get root_url
    assert_response :success
  end

  test "should get contact without authentication" do
    get contact_url
    assert_response :success
  end

  test "should get trees_of_blakeley_signs without authentication" do
    get trees_of_blakeley_signs_url
    assert_response :success
  end

  test "authenticated user should access home" do
    sign_in users(:one)
    get root_url
    assert_response :success
  end

  test "authenticated user should access contact" do
    sign_in users(:one)
    get contact_url
    assert_response :success
  end

  test "authenticated user should access trees_of_blakeley_signs" do
    sign_in users(:one)
    get trees_of_blakeley_signs_url
    assert_response :success
  end
end
