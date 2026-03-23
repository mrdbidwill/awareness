require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "home is public" do
    get root_url
    assert_response :success
  end

  test "contact page is public" do
    get contact_url
    assert_response :success
  end

  test "terms page is public" do
    get terms_url
    assert_response :success
  end

  test "authenticated users can access home" do
    sign_in users(:one)
    get root_url
    assert_response :success
  end
end
