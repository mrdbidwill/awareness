require "test_helper"

class Admin::StorageLocationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_user = users(:one)
    @admin_user.permission_id = 2
    sign_in @admin_user

    @storage_location = StorageLocation.create!(
      name: "Test Location",
      description: "Test description"
    )
  end

  test "should get index" do
    get admin_storage_locations_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_storage_location_url
    assert_response :success
  end

  test "should create storage_location" do
    assert_difference("StorageLocation.count") do
      post admin_storage_locations_url, params: {
        storage_location: {
          name: "New Location",
          description: "New description"
        }
      }
    end

    assert_redirected_to admin_storage_location_url(StorageLocation.last)
    assert_equal "Storage Location was successfully created.", flash[:notice]
  end

  test "should show storage_location" do
    get admin_storage_location_url(@storage_location)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_storage_location_url(@storage_location)
    assert_response :success
  end

  test "should update storage_location" do
    patch admin_storage_location_url(@storage_location), params: {
      storage_location: {
        name: "Updated Location"
      }
    }

    assert_redirected_to admin_storage_location_url(@storage_location)
    assert_equal "Storage Location was successfully updated.", flash[:notice]
  end

  test "should destroy storage_location" do
    deletable = StorageLocation.create!(name: "Deletable")

    assert_difference("StorageLocation.count", -1) do
      delete admin_storage_location_url(deletable)
    end

    assert_redirected_to admin_storage_locations_url
    assert_equal "Storage Location was successfully deleted.", flash[:notice]
  end

  test "should handle invalid creation" do
    assert_no_difference("StorageLocation.count") do
      post admin_storage_locations_url, params: {
        storage_location: {
          name: ""  # Invalid
        }
      }
    end

    assert_response :unprocessable_entity
  end
end
