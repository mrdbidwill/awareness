require "test_helper"

class Admin::MbListsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @mb_list = mb_lists(:one)
    @admin_user = users(:one)
    @admin_user.permission_id = 2
    @admin_user.save!
    sign_in @admin_user
  end

  test "should get index" do
    get admin_mb_lists_url
    assert_response :success
  end

  test "should get index as json" do
    get admin_mb_lists_url, as: :json
    assert_response :success
  end

  test "should get new" do
    get new_admin_mb_list_url
    assert_response :success
  end

  test "should show mb_list" do
    get admin_mb_list_url(@mb_list)
    assert_response :success
  end

  test "should create mb_list" do
    assert_difference("MbList.count") do
      post admin_mb_lists_url, params: {
        mb_list: {
          taxon_name: "New Taxon",
          description: "Test description",
          comments: "Test comments"
        }
      }
    end

    assert_redirected_to admin_mb_list_url(MbList.last)
    assert_equal "MbList was successfully created.", flash[:notice]
  end

  test "should get edit" do
    get edit_admin_mb_list_url(@mb_list)
    assert_response :success
  end

  test "should update mb_list" do
    patch admin_mb_list_url(@mb_list), params: {
      mb_list: {
        taxon_name: "Updated Taxon"
      }
    }

    assert_redirected_to admin_mb_list_url(@mb_list)
    assert_equal "MbList was successfully updated.", flash[:notice]
  end

  test "should destroy mb_list" do
    assert_difference("MbList.count", -1) do
      delete admin_mb_list_url(@mb_list)
    end

    assert_redirected_to admin_mb_lists_url
    assert_equal "MbList was successfully deleted.", flash[:notice]
  end

  test "should handle invalid creation" do
    assert_no_difference("MbList.count") do
      post admin_mb_lists_url, params: {
        mb_list: {
          taxon_name: ""  # Invalid - required field
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should show all mb_lists to admin" do
    other_list = MbList.create!(taxon_name: "Other List")

    get admin_mb_list_url(other_list)
    assert_response :success
  end
end
