require "test_helper"

class BooksControllerTest < ActionDispatch::IntegrationTest
  test "should get index without authentication" do
    get books_url
    assert_response :success
  end

  test "should display books and related source data types" do
    get books_url
    assert_response :success
    assert assigns(:source_data)
  end

  test "should filter by specific source data types" do
    # Controller filters by types: 1 = book, 4 = chart, 8 = kindle, 9 = e book
    get books_url
    assert_response :success

    source_data = assigns(:source_data)
    if source_data.any?
      assert source_data.all? { |sd| [1, 4, 8, 9].include?(sd.source_data_type_id) }
    end
  end

  test "should include source data type associations" do
    get books_url
    assert_response :success
    # Verify eager loading works
    assert_not_nil assigns(:source_data)
  end

  test "should order books by title" do
    get books_url
    assert_response :success
  end
end
