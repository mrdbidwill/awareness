require "test_helper"

class ColorsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @color = colors(:one) # Reference your color fixture

    # Sign in user for authentication
    @user = users(:one)
    @user.permission_id = 2
    sign_in @user
  end


  test "should get index" do
    get admin_colors_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_color_url
    assert_response :success
  end

  test "should create color" do
    assert_difference("Color.count", 1) do
      post admin_colors_url, params: {
        color: {
          latin_name: "Unique Latin Name #{SecureRandom.hex(4)}",
          common_name: "Some Common Name",
          color_group: 1,
          hex: "#112233",
          sequence: 42,
          r_val: 17,
          g_val: 34,
          b_val: 51,
          cwc_r: 16,
          cwc_g: 32,
          cwc_b: 48,
          closest_websafe_color: "#102030",
          image_file_address: "image_file_address.jpg",
          metadata: { source: "test" }
        }
      }
    end

    assert_redirected_to admin_color_url(Color.last)
  end


  test "should show color" do
    get admin_color_url(@color)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_color_url(@color)
    assert_response :success
  end

  test "should update color" do
    patch admin_color_url(@color), params: { color: { latin_name: @color.latin_name, common_name: @color.common_name, color_group: @color.color_group } }
    assert_redirected_to admin_color_url(@color)
  end

  test "should destroy color" do
    assert_difference("Color.count", -1) do
      delete admin_color_url(@color)
    end

    assert_redirected_to admin_colors_url
  end
end
