require "test_helper"

class ObservationMethodsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @user = users(:one) # Reference your user fixture
    @user.permission_id = 2 # Set admin permission
    @observation_method = observation_methods(:one) # Reference your observation_method fixture
    sign_in @user # Devise helper to sign in the user
  end


  test "should get index" do
    get admin_observation_methods_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_observation_method_url
    assert_response :success
  end

  test "should create observation_method" do
    assert_difference("ObservationMethod.count") do
      post admin_observation_methods_url, params: { observation_method: { comments: "New comment", description: "New description", name: "New Observation Method" } }
    end

    assert_redirected_to admin_observation_method_url(ObservationMethod.last)
  end

  test "should show observation_method" do
    get admin_observation_method_url(@observation_method)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_observation_method_url(@observation_method)
    assert_response :success
  end

  test "should update observation_method" do
    patch admin_observation_method_url(@observation_method), params: { observation_method: { comments: @observation_method.comments, description: @observation_method.description, name: @observation_method.name } }
    assert_redirected_to admin_observation_method_url(@observation_method)
  end

  test "should not destroy observation_method with foreign key constraint" do
    # ObservationMethods are referenced by MrCharacters, so deletion should fail
    assert_no_difference("ObservationMethod.count") do
      assert_raises(ActiveRecord::InvalidForeignKey) do
        delete admin_observation_method_url(@observation_method)
      end
    end
  end
end
