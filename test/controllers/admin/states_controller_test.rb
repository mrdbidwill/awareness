require "test_helper"

class Admin::StatesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @state = states(:one)
    @country = countries(:one)
    @admin_user = users(:one)
    @admin_user.permission_id = 2
    sign_in @admin_user
  end

  test "should get index" do
    get admin_states_url
    assert_response :success
  end

  test "should get index filtered by country" do
    get admin_states_url, params: { country_id: @country.id }
    assert_response :success
  end

  test "should render partial when country_id param present" do
    get admin_states_url, params: { country_id: @country.id }
    assert_template partial: "admin/states/_select"
  end

  test "should get new" do
    get new_admin_state_url
    assert_response :success
  end

  test "should create state" do
    assert_difference("State.count") do
      post admin_states_url, params: {
        state: {
          name: "New State",
          country_id: @country.id,
          description: "Test description"
        }
      }
    end

    assert_redirected_to admin_state_url(State.last)
    assert_equal "State was successfully created.", flash[:notice]
  end

  test "should show state" do
    get admin_state_url(@state)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_state_url(@state)
    assert_response :success
  end

  test "should update state" do
    patch admin_state_url(@state), params: {
      state: {
        name: "Updated State"
      }
    }

    assert_redirected_to admin_state_url(@state)
    assert_equal "State was successfully updated.", flash[:notice]
  end

  test "should destroy state" do
    # Create a state without mushrooms
    deletable = State.create!(name: "Deletable", country_id: @country.id)

    assert_difference("State.count", -1) do
      delete admin_state_url(deletable)
    end

    assert_redirected_to admin_states_url
    assert_equal "State was successfully deleted.", flash[:notice]
  end

  test "should handle invalid creation" do
    assert_no_difference("State.count") do
      post admin_states_url, params: {
        state: {
          name: ""  # Invalid
        }
      }
    end

    assert_response :unprocessable_entity
  end
end
