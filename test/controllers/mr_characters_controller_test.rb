require "test_helper"

class MrCharacterControllerTest < ActionDispatch::IntegrationTest

  setup do
    @user = users(:one) # Reference your user fixture
    @user.permission_id = 2 # Set admin permission
    @mr_character = mr_characters(:one) # Reference your mr_character fixture
    sign_in @user # Devise helper to sign in the user
  end


  test "should get index" do
    get admin_mr_characters_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_mr_character_url
    assert_response :success
  end

  test "should create mr_character" do
    # Get valid IDs from database
    part = Part.first
    observation_method = ObservationMethod.first
    display_option = DisplayOption.first
    source_data = SourceData.first

    assert_difference("MrCharacter.count") do
      post admin_mr_characters_url, params: { mr_character: {
        name: "New Character #{Time.now.to_i}",
        description: "New description",
        comments: "New comment",
        part_id: part.id,
        observation_method_id: observation_method.id,
        display_option_id: display_option.id,
        source_data_id: source_data.id
      } }
    end

    assert_redirected_to admin_mr_characters_url
  end

  test "should show mr_character" do
    get admin_mr_character_url(@mr_character)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_mr_character_url(@mr_character)
    assert_response :success
  end

  test "should update mr_character" do
    patch admin_mr_character_url(@mr_character), params: { mr_character: {
      name: @mr_character.name,
      description: @mr_character.description,
      comments: @mr_character.comments,
      part_id: @mr_character.part_id,
      observation_method_id: @mr_character.observation_method_id,
      display_option_id: @mr_character.display_option_id,
      source_data_id: @mr_character.source_data_id
    } }
    assert_redirected_to admin_mr_characters_url
  end

  test "should destroy mr_character" do
    # Change user to Owner permission for delete
    @user.permission_id = 1
    @user.save!

    assert_difference("MrCharacter.count", -1) do
      delete admin_mr_character_url(@mr_character)
    end

    assert_redirected_to admin_mr_characters_url
  end
end
