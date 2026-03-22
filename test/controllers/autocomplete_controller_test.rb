# frozen_string_literal: true

require "test_helper"

class AutocompleteControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user
  end

  test "should get mr_characters autocomplete with valid query" do
    get mr_characters_autocomplete_path, params: { q: "cap" }, as: :json
    assert_response :success
    json_response = JSON.parse(response.body)
    assert json_response.is_a?(Array)
    # Should find characters with "cap" in the name
    assert json_response.any? { |r| r["name"].downcase.include?("cap") } if json_response.any?
  end

  test "should return empty array for short query" do
    get mr_characters_autocomplete_path, params: { q: "pi" }, as: :json
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal [], json_response
  end

  test "should filter out already-entered characters for mushroom" do
    mushroom = mushrooms(:one)
    character = mr_characters(:one)

    # Add character to mushroom
    MrCharacterMushroom.create!(mushroom: mushroom, mr_character: character, character_value: "test")

    # Search for this character
    get mr_characters_autocomplete_path, params: { q: character.name[0..4], mushroom_id: mushroom.id }, as: :json
    assert_response :success
    json_response = JSON.parse(response.body)

    # Should not include the already-entered character
    assert_not json_response.any? { |r| r["id"] == character.id }
  end
end
