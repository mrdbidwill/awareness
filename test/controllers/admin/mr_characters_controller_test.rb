require "test_helper"

class Admin::MrCharactersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @mr_character = mr_characters(:one)
    @admin_user = users(:one)
    @admin_user.permission_id = 2
    sign_in @admin_user
  end

  test "should get index" do
    get admin_mr_characters_url
    assert_response :success
  end

  test "should get index with search query" do
    get admin_mr_characters_url, params: { q: @mr_character.name }
    assert_response :success
  end

  test "should get index with search by id" do
    get admin_mr_characters_url, params: { q: @mr_character.id.to_s }
    assert_response :success
  end

  test "should get index with part filter" do
    get admin_mr_characters_url, params: { part_id: @mr_character.part_id }
    assert_response :success
  end

  test "should get index with observation method filter" do
    get admin_mr_characters_url, params: { observation_method_id: "universal" }
    assert_response :success
  end

  test "should get index with fungus type filter" do
    get admin_mr_characters_url, params: { fungus_type_id: "universal" }
    assert_response :success
  end

  test "should get new" do
    get new_admin_mr_character_url
    assert_response :success
  end

  test "should create mr_character" do
    assert_difference("MrCharacter.count") do
      post admin_mr_characters_url, params: {
        mr_character: {
          name: "New Character #{Time.now.to_i}",
          part_id: @mr_character.part_id,
          observation_method_id: @mr_character.observation_method_id,
          display_option_id: @mr_character.display_option_id,
          source_data_id: @mr_character.source_data_id
        }
      }
    end

    assert_redirected_to admin_mr_characters_url
    assert_equal "Character created successfully.", flash[:notice]
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
    patch admin_mr_character_url(@mr_character), params: {
      mr_character: {
        name: "Updated Character"
      }
    }

    assert_redirected_to admin_mr_characters_url
    assert_equal "Character updated successfully.", flash[:notice]
  end

  test "should update and preserve page param" do
    patch admin_mr_character_url(@mr_character), params: {
      page: 2,
      mr_character: {
        name: "Updated with Page"
      }
    }

    assert_redirected_to admin_mr_characters_url(page: 2)
  end

  test "should destroy mr_character" do
    # Create one with all required associations
    source_data = SourceData.first || SourceData.create!(name: "Test Source")
    deletable = MrCharacter.create!(
      name: "Deletable",
      part_id: @mr_character.part_id,
      observation_method_id: @mr_character.observation_method_id,
      display_option_id: @mr_character.display_option_id,
      source_data_id: source_data.id
    )

    assert_difference("MrCharacter.count", -1) do
      delete admin_mr_character_url(deletable)
    end

    assert_redirected_to admin_mr_characters_url
    assert_equal "Character deleted successfully.", flash[:notice]
  end

  test "should handle invalid creation" do
    assert_no_difference("MrCharacter.count") do
      post admin_mr_characters_url, params: {
        mr_character: {
          name: ""  # Invalid
        }
      }
    end

    assert_response :unprocessable_entity
  end
end
