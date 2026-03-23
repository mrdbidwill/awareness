require "test_helper"

class BooksControllerTest < ActionDispatch::IntegrationTest
  test "index is publicly accessible" do
    get books_url
    assert_response :success
  end

  test "index renders curated books content" do
    get books_url
    assert_response :success

    assert_includes response.body, "Books & References"
    assert_includes response.body, "Mushrooms Demystified"
  end
end
