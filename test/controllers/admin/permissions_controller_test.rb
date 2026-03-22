require "test_helper"

class Admin::PermissionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_user = users(:one)
    @admin_user.permission_id = 2
    sign_in @admin_user

    @permission = Permission.create!(
      name: "Test Permission",
      description: "Test description"
    )
  end

  test "should get index" do
    get admin_permissions_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_permission_url
    assert_response :success
  end

  test "should create permission" do
    assert_difference("Permission.count") do
      post admin_permissions_url, params: {
        permission: {
          name: "New Permission",
          description: "New description"
        }
      }
    end

    assert_redirected_to admin_permission_url(Permission.last)
    assert_equal "Camera make was successfully created.", flash[:notice]
  end

  test "should show permission" do
    get admin_permission_url(@permission)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_permission_url(@permission)
    assert_response :success
  end

  test "should update permission" do
    patch admin_permission_url(@permission), params: {
      permission: {
        name: "Updated Permission"
      }
    }

    assert_redirected_to admin_permission_url(@permission)
    assert_equal "Camera make was successfully updated.", flash[:notice]
  end

  test "should destroy permission" do
    deletable = Permission.create!(name: "Deletable")

    assert_difference("Permission.count", -1) do
      delete admin_permission_url(deletable)
    end

    assert_redirected_to admin_permissions_url
    assert_equal "Camera make was successfully deleted.", flash[:notice]
  end

  test "should handle invalid creation" do
    assert_no_difference("Permission.count") do
      post admin_permissions_url, params: {
        permission: {
          name: ""  # Invalid
        }
      }
    end

    assert_response :unprocessable_entity
  end
end
