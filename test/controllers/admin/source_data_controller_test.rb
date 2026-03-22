require "test_helper"

class SourceDataControllerTest < ActionDispatch::IntegrationTest

  setup do
    @user = users(:one)
    @user.permission_id = 2
    sign_in @user

    # Create source_data directly instead of using fixtures to avoid fixture loading issues
    source_data_type = SourceDataType.first || SourceDataType.create!(name: "Test Type", description: "Test")
    @source_data = SourceData.find_or_create_by!(
      title: "Test Source Data",
      author: "Test Author",
      ref: "TEST123",
      item_code: "ITEM123",
      source_data_type_id: source_data_type.id,
      comments: "Test comment"
    )
  end


  test "should get index" do
    get admin_source_data_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_source_datum_url
    assert_response :success
  end

  test "should create source_data" do
    source_data_type = SourceDataType.first
    assert_difference("SourceData.count") do
      post admin_source_data_url, params: { source_data: {
        title: "New Source #{Time.now.to_i}",
        author: "New Author",
        ref: "12345",
        item_code: "ABC123",
        source_data_type_id: source_data_type.id,
        comments: "New comment"
      } }
    end

    assert_redirected_to admin_source_datum_path(SourceData.last)
  end

  test "should create source_data and return to originating page when return_to parameter present" do
    source_data_type = SourceDataType.first
    return_path = new_admin_mr_character_path

    assert_difference("SourceData.count") do
      post admin_source_data_url, params: {
        source_data: {
          title: "New Source #{Time.now.to_i}",
          author: "New Author",
          ref: "12345",
          item_code: "ABC123",
          source_data_type_id: source_data_type.id,
          comments: "New comment"
        },
        return_to: return_path
      }
    end

    assert_redirected_to return_path
  end

  test "should show source_data" do
    get admin_source_datum_path(@source_data)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_source_datum_path(@source_data)
    assert_response :success
  end

  test "should update source_data" do
    patch admin_source_datum_path(@source_data), params: { source_data: {
      title: @source_data.title,
      author: @source_data.author,
      ref: @source_data.ref,
      item_code: @source_data.item_code,
      comments: @source_data.comments,
      source_data_type_id: @source_data.source_data_type_id
    } }
    assert_redirected_to admin_source_data_path
  end

  test "should destroy source_data" do
    assert_difference("SourceData.count", -1) do
      delete admin_source_datum_path(@source_data)
    end

    assert_redirected_to admin_source_data_url
  end
end
