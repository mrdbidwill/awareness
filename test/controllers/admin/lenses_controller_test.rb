require "test_helper"

class Admin::LensesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @lens = lenses(:one)
    @admin_user = users(:one)
    @admin_user.permission_id = 2
    sign_in @admin_user
  end

  test "should get index" do
    get admin_lenses_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_lens_url
    assert_response :success
  end

  test "should create lens" do
    assert_difference("Lens.count") do
      post admin_lenses_url, params: {
        lens: {
          make: "Canon",
          model: "50mm f/1.8",
          description: "Prime lens",
          comments: "Great lens"
        }
      }
    end

    assert_redirected_to admin_lenses_url
    assert_equal "Lens successfully created.", flash[:notice]
  end

  test "should show lens" do
    get admin_lens_url(@lens)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_lens_url(@lens)
    assert_response :success
  end

  test "should update lens" do
    patch admin_lens_url(@lens), params: {
      lens: {
        make: "Updated Make",
        model: @lens.model
      }
    }

    assert_redirected_to admin_lenses_url
    assert_equal "Lens successfully updated.", flash[:notice]
  end

  test "should destroy lens" do
    # Create a lens without associations
    deletable = Lens.create!(make: "Test", model: "Deletable")

    assert_difference("Lens.count", -1) do
      delete admin_lens_url(deletable)
    end

    assert_redirected_to admin_lenses_url
    assert_equal "Lens successfully deleted.", flash[:notice]
  end

  test "should handle invalid creation" do
    assert_no_difference("Lens.count") do
      post admin_lenses_url, params: {
        lens: {
          make: "",  # Invalid - required fields
          model: ""
        }
      }
    end

    assert_response :unprocessable_entity
  end
end
