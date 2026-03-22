require "test_helper"
class DisplayOptionsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @user = users(:one) # Reference your user fixture
    @user.permission_id = 2 # Set admin permission
    @display_option = display_options(:one) # Reference your display_option fixture
    sign_in @user # Devise helper to sign in the user
  end


  test "should get index" do
    get admin_display_options_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_display_option_url
    assert_response :success
  end

  test "should create display_option" do
    assert_difference("DisplayOption.count") do
      post admin_display_options_url, params: { display_option: { comments: "New comment", description: "New description", name: "New Display Option" } }
    end

    assert_redirected_to admin_display_option_url(DisplayOption.last)
  end

  test "should show display_option" do
    get admin_display_option_url(@display_option)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_display_option_url(@display_option)
    assert_response :success
  end

  test "should update display_option" do
    patch admin_display_option_url(@display_option), params: { display_option: { comments: @display_option.comments, description: @display_option.description, name: @display_option.name } }
    assert_redirected_to admin_display_option_url(@display_option)
  end

  test "should not destroy display_option with foreign key constraint" do
    # DisplayOptions are referenced by MrCharacters, so deletion should fail
    assert_no_difference("DisplayOption.count") do
      assert_raises(ActiveRecord::InvalidForeignKey) do
        delete admin_display_option_url(@display_option)
      end
    end
  end
end
