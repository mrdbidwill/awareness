require "test_helper"

class Admin::FungusTypesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @fungus_type = fungus_types(:one)
    @admin_user = users(:one)
    @admin_user.permission_id = 2
    sign_in @admin_user
  end

  test "should get index" do
    get admin_fungus_types_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_fungus_type_url
    assert_response :success
  end

  test "should create fungus_type" do
    assert_difference("FungusType.count") do
      post admin_fungus_types_url, params: {
        fungus_type: {
          name: "New Fungus Type",
          description: "Test description",
          comments: "Test comments"
        }
      }
    end

    assert_redirected_to admin_fungus_type_url(FungusType.last)
    assert_equal "Fungus type was successfully created.", flash[:notice]
  end

  test "should show fungus_type" do
    get admin_fungus_type_url(@fungus_type)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_fungus_type_url(@fungus_type)
    assert_response :success
  end

  test "should update fungus_type" do
    patch admin_fungus_type_url(@fungus_type), params: {
      fungus_type: {
        name: "Updated Fungus Type",
        description: @fungus_type.description
      }
    }

    assert_redirected_to admin_fungus_type_url(@fungus_type)
    assert_equal "Fungus type was successfully updated.", flash[:notice]
  end

  test "should destroy fungus_type" do
    # Create a fungus type without associations
    deletable = FungusType.create!(name: "Deletable Type")

    assert_difference("FungusType.count", -1) do
      delete admin_fungus_type_url(deletable)
    end

    assert_redirected_to admin_fungus_types_url
    assert_equal "Fungus type was successfully deleted.", flash[:notice]
  end

  test "should handle invalid creation" do
    assert_no_difference("FungusType.count") do
      post admin_fungus_types_url, params: {
        fungus_type: {
          name: ""  # Invalid - name is required
        }
      }
    end

    assert_response :unprocessable_entity
  end
end
