require "test_helper"

class Admin::SourceDataTypesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_user = users(:one)
    @admin_user.permission_id = 2
    sign_in @admin_user

    @source_data_type = SourceDataType.create!(
      name: "Test Type",
      description: "Test description"
    )
  end

  test "should get index" do
    get admin_source_data_types_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_source_data_type_url
    assert_response :success
  end

  test "should create source_data_type" do
    assert_difference("SourceDataType.count") do
      post admin_source_data_types_url, params: {
        source_data_type: {
          name: "New Type",
          description: "New description"
        }
      }
    end

    assert_redirected_to admin_source_data_type_url(SourceDataType.last)
    assert_equal "Source data  type was successfully created.", flash[:notice]
  end

  test "should show source_data_type" do
    get admin_source_data_type_url(@source_data_type)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_source_data_type_url(@source_data_type)
    assert_response :success
  end

  test "should update source_data_type" do
    patch admin_source_data_type_url(@source_data_type), params: {
      source_data_type: {
        name: "Updated Type"
      }
    }

    assert_redirected_to admin_source_data_type_url(@source_data_type)
    assert_equal "Source data  type was successfully updated.", flash[:notice]
  end

  test "should destroy source_data_type" do
    deletable = SourceDataType.create!(name: "Deletable")

    assert_difference("SourceDataType.count", -1) do
      delete admin_source_data_type_url(deletable)
    end

    assert_redirected_to admin_source_data_types_url
    assert_equal "Source data  type was successfully deleted.", flash[:notice]
  end

  test "should handle invalid creation" do
    assert_no_difference("SourceDataType.count") do
      post admin_source_data_types_url, params: {
        source_data_type: {
          name: ""  # Invalid
        }
      }
    end

    assert_response :unprocessable_entity
  end
end
