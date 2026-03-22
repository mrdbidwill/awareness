require "test_helper"

class Admin::LookupItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @lookup_item = lookup_items(:one)
    @admin_user = users(:one)
    @admin_user.permission_id = 2
    sign_in @admin_user
  end

  test "should get index" do
    get admin_lookup_items_url
    assert_response :success
  end

  test "should get index with character filter" do
    get admin_lookup_items_url, params: { mr_character_id: @lookup_item.mr_character_id }
    assert_response :success
  end

  test "should get new" do
    get new_admin_lookup_item_url
    assert_response :success
  end

  test "should show lookup_item" do
    get admin_lookup_item_url(@lookup_item)
    assert_response :success
  end

  test "should create lookup_item" do
    mr_char = mr_characters(:one)
    source = SourceData.first || SourceData.create!(title: "Test Source")

    assert_difference("LookupItem.count") do
      post admin_lookup_items_url, params: {
        lookup_item: {
          mr_character_id: mr_char.id,
          source_data_id: source.id,
          name: "Completely New Lookup Item #{Time.now.to_i}",
          description: "Test description"
        }
      }
    end

    assert_redirected_to admin_lookup_items_url
    assert_equal "Lookup item created successfully.", flash[:notice]
  end

  test "should get edit" do
    get edit_admin_lookup_item_url(@lookup_item)
    assert_response :success
  end

  test "should update lookup_item" do
    patch admin_lookup_item_url(@lookup_item), params: {
      lookup_item: {
        name: "Updated Name"
      }
    }

    assert_redirected_to admin_lookup_items_url
    assert_equal "Lookup item updated successfully.", flash[:notice]
  end

  test "should update and redirect with mr_character_id filter" do
    patch admin_lookup_item_url(@lookup_item), params: {
      mr_character_id: @lookup_item.mr_character_id,
      lookup_item: {
        name: "Updated with Filter"
      }
    }

    assert_redirected_to admin_lookup_items_url(mr_character_id: @lookup_item.mr_character_id)
  end

  test "should destroy lookup_item" do
    @admin_user.permission_id = 1  # Owner permission required for destroy
    @admin_user.save!

    assert_difference("LookupItem.count", -1) do
      delete admin_lookup_item_url(@lookup_item)
    end

    assert_redirected_to admin_lookup_items_url
    assert_equal "Lookup item deleted successfully.", flash[:notice]
  end

  test "should handle invalid creation" do
    assert_no_difference("LookupItem.count") do
      post admin_lookup_items_url, params: {
        lookup_item: {
          name: ""  # Invalid
        }
      }
    end

    assert_response :unprocessable_entity
  end
end
