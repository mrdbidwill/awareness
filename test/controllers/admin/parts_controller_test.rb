require "test_helper"

class PartsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @user = users(:one) # Reference your user fixture
    @user.permission_id = 2 # Set admin permission
    @part = parts(:one) # Reference your part fixture
    sign_in @user # Devise helper to sign in the user
  end


  test "should get index" do
    get admin_parts_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_part_url
    assert_response :success
  end

  test "should create part" do
    assert_difference("Part.count") do
      post admin_parts_url, params: { part: { comments: "New comment", description: "New description", name: "New Part Name" } }
    end

    assert_redirected_to admin_part_url(Part.last)
  end

  test "should show part" do
    get admin_part_url(@part)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_part_url(@part)
    assert_response :success
  end

  test "should update part" do
    patch admin_part_url(@part), params: { part: { comments: @part.comments, description: @part.description, name: @part.name } }
    assert_redirected_to admin_part_url(@part)
  end

  test "should not destroy part with foreign key constraint" do
    # Parts are referenced by MrCharacters, so deletion should fail
    assert_no_difference("Part.count") do
      assert_raises(ActiveRecord::InvalidForeignKey) do
        delete admin_part_url(@part)
      end
    end
  end
end
