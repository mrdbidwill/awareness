require "test_helper"

class MushroomSearchControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @mushroom = mushrooms(:one)
    @mushroom.user = @user
    @mushroom.save!
    @fungus_type = fungus_types(:one)
    sign_in @user
  end

  test "should get index" do
    get mushroom_search_index_url
    assert_response :success
  end

  test "should search with text query" do
    get mushroom_search_index_url, params: { q: "test" }
    assert_response :success
    assert assigns(:query)
  end

  test "should filter by fungus type" do
    get mushroom_search_index_url, params: { fungus_type_id: @fungus_type.id }
    assert_response :success
    assert assigns(:fungus_type_id)
  end

  test "should filter by character values" do
    mr_character = mr_characters(:one)

    get mushroom_search_index_url, params: {
      character_ids: [mr_character.id.to_s],
      character_values: ["test value"]
    }

    assert_response :success
  end

  test "should handle multiple character filters" do
    mr_character = mr_characters(:one)
    mr_character_two = mr_characters(:two)

    get mushroom_search_index_url, params: {
      character_ids: [mr_character.id.to_s, mr_character_two.id.to_s],
      character_values: ["test value", "another value"]
    }

    assert_response :success
  end

  test "should combine multiple filters" do
    mr_character = mr_characters(:one)
    mr_character_two = mr_characters(:two)

    get mushroom_search_index_url, params: {
      q: "test",
      fungus_type_id: @fungus_type.id,
      character_ids: [mr_character.id.to_s],
      character_values: ["value"]
    }

    assert_response :success
  end

  test "should paginate results" do
    get mushroom_search_index_url, params: { page: 1 }
    assert_response :success
  end

  test "should load fungus types for filter" do
    get mushroom_search_index_url
    assert_response :success
    assert assigns(:fungus_types)
  end

  test "should search ALL mushrooms regardless of ownership" do
    other_user = users(:two)
    other_mushroom = Mushroom.create!(
      user: other_user,
      name: "Other User Mushroom",
      collection_date: Date.today,
      country_id: countries(:one).id,
      fungus_type_id: fungus_types(:one).id
    )

    get mushroom_search_index_url
    assert_response :success

    mushrooms = assigns(:mushrooms)
    assert_includes mushrooms, other_mushroom
  end

  test "should exclude template mushrooms" do
    get mushroom_search_index_url
    assert_response :success
    # Templates should be excluded
  end

  test "should require authentication" do
    sign_out @user

    get mushroom_search_index_url
    assert_redirected_to new_user_session_path
  end

  test "should autocomplete characters" do
    mr_character = mr_characters(:one)

    get mushroom_search_autocomplete_characters_url, params: { q: mr_character.name[0..2] }, as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert json_response.is_a?(Array)
  end

  test "should return empty array for autocomplete without query" do
    get mushroom_search_autocomplete_characters_url, as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal [], json_response
  end
end
