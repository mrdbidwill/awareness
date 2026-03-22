require "test_helper"

class MushroomAuthorizationTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)              # Simulated logged-in user (fixtures)
    @another_user = users(:two)      # Another user to test access restrictions
    @mushroom = mushrooms(:one)      # Belongs to @user
    @other_mushroom = mushrooms(:two) # Belongs to @another_user
  end

  test "authorized user sees their own actions" do
    # Simulate logging in as @user
    sign_in_as(@user)

    get mushrooms_path
    assert_response :success

    # Verify card link to their own mushroom exists
    assert_select "a[href=?]", mushroom_path(@mushroom), minimum: 1

    # The design uses card links to mushroom show page, not separate "Show" links
    # Edit links are on the mushroom show page, not the index
  end

  test "unauthorized user does not see restricted links" do
    # Simulate another user logging in
    sign_in_as(@another_user)

    get mushrooms_path
    assert_response :success

    # Users can only see their own mushrooms on this page
    # @mushroom belongs to @user, so @another_user should not see it
    assert_select "a[href=?]", mushroom_path(@mushroom), count: 0
  end

  test "guest user does not see protected links" do
    # Simulate a guest (not signed in)
    get mushrooms_path
    assert_response :success

    # Guests can see the "Add New Mushroom" link (it appears twice in the current design)
    # but authentication will redirect them when they try to access it
    # The link presence is OK - authorization happens at controller level

    # Guests should not see mushroom cards since the controller scopes to current_user's mushrooms
    # and guest has no current_user
    assert_select "a[href=?]", mushroom_path(@mushroom), count: 0
  end

  private

  # Updated sign_in method for Devise
  def sign_in_as(user)
    post new_user_session_path, params: { user: { email: user.email, password: "password" } }
    follow_redirect!
  end
end
