require "test_helper"

class Admin::RolesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_user = users(:one)
    @admin_user.permission_id = 2
    sign_in @admin_user

    @role = Role.create!(
      name: "Test Role",
      description: "Test description"
    )
  end

  test "should get index" do
    get admin_roles_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_role_url
    assert_response :success
  end

  test "should create role" do
    assert_difference("Role.count") do
      post admin_roles_url, params: {
        role: {
          name: "New Role",
          description: "New description"
        }
      }
    end

    assert_redirected_to admin_role_url(Role.last)
    assert_equal "Role was successfully created.", flash[:notice]
  end

  test "should show role" do
    get admin_role_url(@role)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_role_url(@role)
    assert_response :success
  end

  test "should update role" do
    patch admin_role_url(@role), params: {
      role: {
        name: "Updated Role"
      }
    }

    assert_redirected_to admin_role_url(@role)
    assert_equal "Role was successfully updated.", flash[:notice]
  end

  test "should destroy role" do
    deletable = Role.create!(name: "Deletable")

    assert_difference("Role.count", -1) do
      delete admin_role_url(deletable)
    end

    assert_redirected_to admin_roles_url
    assert_equal "Role was successfully deleted.", flash[:notice]
  end

  test "should handle invalid creation" do
    assert_no_difference("Role.count") do
      post admin_roles_url, params: {
        role: {
          name: ""  # Invalid
        }
      }
    end

    assert_response :unprocessable_entity
  end
end
