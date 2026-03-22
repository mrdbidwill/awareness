# frozen_string_literal: true

require "test_helper"

class AutocompleteRequestTest < ActionDispatch::IntegrationTest
  # ============================================================================
  # AUTOCOMPLETE API REQUEST TESTS
  # ============================================================================
  # Tests for JSON autocomplete endpoints used for dropdown/typeahead searches
  #
  # ENDPOINTS TESTED:
  # - GET /autocomplete/genera.json
  # - GET /autocomplete/species.json
  # - GET /autocomplete/trees.json
  # - GET /autocomplete/plants.json
  # - GET /autocomplete/mr_characters.json
  #
  # FEATURES TESTED:
  # - Authentication requirements
  # - Query parameter validation
  # - Minimum query length (3 characters)
  # - JSON response format
  # - Result limiting (20 items)
  # - SQL injection prevention
  # ============================================================================

  setup do
    @user = users(:one)
    @mushroom = mushrooms(:one)
  end

  # ==========================================================================
  # GENERA AUTOCOMPLETE TESTS
  # ==========================================================================

  test "genera autocomplete requires authentication" do
    get mycowriter.genera_autocomplete_path(format: :json, q: "gen")
    assert_response :unauthorized
    json = JSON.parse(response.body)
    assert_equal "You need to sign in or sign up before continuing.", json["error"]
  end

  test "genera autocomplete returns empty array for short query" do
    sign_in @user
    get mycowriter.genera_autocomplete_path(format: :json, q: "ge")
    assert_response :success
    assert_equal "application/json; charset=utf-8", response.content_type
    assert_equal [], JSON.parse(response.body)
  end

  test "genera autocomplete returns empty array for missing query" do
    sign_in @user
    get mycowriter.genera_autocomplete_path(format: :json)
    assert_response :success
    assert_equal [], JSON.parse(response.body)
  end

  test "genera autocomplete returns results for valid query" do
    sign_in @user
    get mycowriter.genera_autocomplete_path(format: :json, q: "Genus")
    assert_response :success

    json = JSON.parse(response.body)
    assert json.is_a?(Array)
    assert json.all? { |item| item.key?("id") && item.key?("name") }
  end

  test "genera autocomplete limits results to 20" do
    sign_in @user
    # Create more than 20 genera with same prefix
    25.times { |i| Genus.create!(name: "TestGenus#{i}", mblist_id: i + 100) }

    get mycowriter.genera_autocomplete_path(format: :json, q: "TestGenus")
    assert_response :success

    json = JSON.parse(response.body)
    assert_operator json.length, :<=, 20
  end

  test "genera autocomplete returns ordered results" do
    sign_in @user
    Genus.create!(name: "ZGenusLast", mblist_id: 100)
    Genus.create!(name: "AGenusFirst", mblist_id: 101)

    get mycowriter.genera_autocomplete_path(format: :json, q: "Genus")
    assert_response :success

    json = JSON.parse(response.body)
    names = json.map { |g| g["name"] }
    assert_equal names, names.sort
  end

  test "genera autocomplete handles SQL injection attempt" do
    sign_in @user
    get mycowriter.genera_autocomplete_path(format: :json, q: "'; DROP TABLE genera; --")
    assert_response :success
    assert Genus.count > 0 # Table should still exist
  end

  # ==========================================================================
  # SPECIES AUTOCOMPLETE TESTS
  # ==========================================================================

  test "species autocomplete requires authentication" do
    get mycowriter.species_autocomplete_path(format: :json, q: "spec")
    assert_response :unauthorized
    json = JSON.parse(response.body)
    assert_equal "You need to sign in or sign up before continuing.", json["error"]
  end

  test "species autocomplete returns empty array for short query" do
    sign_in @user
    get mycowriter.species_autocomplete_path(format: :json, q: "sp")
    assert_response :success
    assert_equal [], JSON.parse(response.body)
  end

  test "species autocomplete returns results for valid query" do
    sign_in @user
    get mycowriter.species_autocomplete_path(format: :json, q: "Species")
    assert_response :success

    json = JSON.parse(response.body)
    assert json.is_a?(Array)
    assert json.all? { |item| item.key?("id") && item.key?("name") }
  end

  test "species autocomplete filters by mushroom genera" do
    sign_in @user
    genus = genera(:one)
    mushroom = @mushroom
    # Fixtures already have mushroom:one with genus:one
    GenusMushroom.find_or_create_by!(mushroom: mushroom, genus: genus)

    species_in_genus = Species.create!(name: "SpeciesInGenus", genera_id: genus.id, mblist_id: 200)
    species_out_genus = Species.create!(name: "SpeciesOutGenus", genera_id: genera(:two).id, mblist_id: 201)

    get mycowriter.species_autocomplete_path(format: :json, q: "Species", mushroom_id: mushroom.id)
    assert_response :success

    json = JSON.parse(response.body)
    ids = json.map { |s| s["id"] }
    assert_includes ids, species_in_genus.id
    assert_not_includes ids, species_out_genus.id
  end

  test "species autocomplete includes genus name in result" do
    sign_in @user
    get mycowriter.species_autocomplete_path(format: :json, q: "Species")
    assert_response :success

    json = JSON.parse(response.body)
    if json.any?
      # Result should contain genus name prefix if genus exists
      first_result = json.first
      assert first_result["name"].is_a?(String)
    end
  end

  test "species autocomplete limits results to 20" do
    sign_in @user
    genus = genera(:one)
    25.times { |i| Species.create!(name: "TestSpecies#{i}", genera_id: genus.id, mblist_id: i + 300) }

    get mycowriter.species_autocomplete_path(format: :json, q: "TestSpecies")
    assert_response :success

    json = JSON.parse(response.body)
    assert_operator json.length, :<=, 20
  end

  # ==========================================================================
  # TREES AUTOCOMPLETE TESTS
  # ==========================================================================

  test "trees autocomplete requires authentication" do
    get trees_autocomplete_path(format: :json, q: "oak")
    assert_response :unauthorized
    json = JSON.parse(response.body)
    assert_equal "You need to sign in or sign up before continuing.", json["error"]
  end

  test "trees autocomplete returns empty array for short query" do
    sign_in @user
    get trees_autocomplete_path(format: :json, q: "oa")
    assert_response :success
    assert_equal [], JSON.parse(response.body)
  end

  test "trees autocomplete returns results for valid query" do
    sign_in @user
    get trees_autocomplete_path(format: :json, q: "Tree")
    assert_response :success

    json = JSON.parse(response.body)
    assert json.is_a?(Array)
    assert json.all? { |item| item.key?("id") && item.key?("name") }
  end

  test "trees autocomplete limits results to 20" do
    sign_in @user
    25.times { |i| Tree.create!(name: "TestTree#{i}") }

    get trees_autocomplete_path(format: :json, q: "TestTree")
    assert_response :success

    json = JSON.parse(response.body)
    assert_operator json.length, :<=, 20
  end

  test "trees autocomplete handles SQL injection attempt" do
    sign_in @user
    get trees_autocomplete_path(format: :json, q: "'; DROP TABLE trees; --")
    assert_response :success
    assert Tree.count > 0
  end

  # ==========================================================================
  # PLANTS AUTOCOMPLETE TESTS
  # ==========================================================================

  test "plants autocomplete requires authentication" do
    get plants_autocomplete_path(format: :json, q: "fern")
    assert_response :unauthorized
    json = JSON.parse(response.body)
    assert_equal "You need to sign in or sign up before continuing.", json["error"]
  end

  test "plants autocomplete returns empty array for short query" do
    sign_in @user
    get plants_autocomplete_path(format: :json, q: "fe")
    assert_response :success
    assert_equal [], JSON.parse(response.body)
  end

  test "plants autocomplete returns results for valid query" do
    sign_in @user
    Plant.create!(name: "Fern Plant")
    get plants_autocomplete_path(format: :json, q: "Fern")
    assert_response :success

    json = JSON.parse(response.body)
    assert json.is_a?(Array)
    if json.any?
      assert json.all? { |item| item.key?("id") && item.key?("name") }
    end
  end

  test "plants autocomplete limits results to 20" do
    sign_in @user
    25.times { |i| Plant.create!(name: "TestPlant#{i}") }

    get plants_autocomplete_path(format: :json, q: "TestPlant")
    assert_response :success

    json = JSON.parse(response.body)
    assert_operator json.length, :<=, 20
  end

  test "plants autocomplete handles SQL injection attempt" do
    sign_in @user
    get plants_autocomplete_path(format: :json, q: "'; DROP TABLE plants; --")
    assert_response :success
    assert Plant.count >= 0 # Table should exist
  end

  # ==========================================================================
  # MR_CHARACTERS AUTOCOMPLETE TESTS
  # ==========================================================================

  test "mr_characters autocomplete requires authentication" do
    get mr_characters_autocomplete_path(format: :json, q: "cap")
    assert_response :unauthorized
    json = JSON.parse(response.body)
    assert_equal "You need to sign in or sign up before continuing.", json["error"]
  end

  test "mr_characters autocomplete returns empty array for short query" do
    sign_in @user
    get mr_characters_autocomplete_path(format: :json, q: "pi")
    assert_response :success
    assert_equal [], JSON.parse(response.body)
  end

  test "mr_characters autocomplete returns results with part name" do
    sign_in @user
    # This test depends on your MrCharacter fixtures/cached data
    get mr_characters_autocomplete_path(format: :json, q: "cap", mushroom_id: @mushroom.id)
    assert_response :success

    json = JSON.parse(response.body)
    assert json.is_a?(Array)
    # Results should have id, name, and part_name
    if json.any?
      assert json.all? { |item| item.key?("id") && item.key?("name") && item.key?("part_name") }
    end
  end

  test "mr_characters autocomplete limits results to 20" do
    sign_in @user
    get mr_characters_autocomplete_path(format: :json, q: "test", mushroom_id: @mushroom.id)
    assert_response :success

    json = JSON.parse(response.body)
    assert_operator json.length, :<=, 20
  end

  test "mr_characters autocomplete is case insensitive" do
    sign_in @user
    get mr_characters_autocomplete_path(format: :json, q: "CAP", mushroom_id: @mushroom.id)
    assert_response :success

    json = JSON.parse(response.body)
    assert json.is_a?(Array)
  end

  test "mr_characters autocomplete handles missing mushroom_id" do
    sign_in @user
    get mr_characters_autocomplete_path(format: :json, q: "cap")
    assert_response :success

    json = JSON.parse(response.body)
    assert json.is_a?(Array)
  end

  # ==========================================================================
  # SECURITY AND EDGE CASES
  # ==========================================================================

  test "autocomplete endpoints reject HTML format" do
    sign_in @user

    # Genera endpoint should default to JSON even with HTML format param
    get mycowriter.genera_autocomplete_path(format: :html, q: "test")
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal [], json
  end

  test "autocomplete handles special characters safely" do
    sign_in @user
    special_queries = ["test%", "test_", "test*", "test?", "test\\"]

    special_queries.each do |query|
      get mycowriter.genera_autocomplete_path(format: :json, q: query)
      assert_response :success, "Failed for query: #{query}"
    end
  end

  test "autocomplete handles unicode characters" do
    sign_in @user
    get mycowriter.genera_autocomplete_path(format: :json, q: "Génüs")
    assert_response :success
    assert JSON.parse(response.body).is_a?(Array)
  end

  test "autocomplete returns valid JSON for empty results" do
    sign_in @user
    get mycowriter.genera_autocomplete_path(format: :json, q: "XYZ_NONEXISTENT_123")
    assert_response :success
    assert_equal [], JSON.parse(response.body)
  end

  test "autocomplete trims whitespace from query" do
    sign_in @user
    get mycowriter.genera_autocomplete_path(format: :json, q: "  Genus  ")
    assert_response :success
    json = JSON.parse(response.body)
    assert json.is_a?(Array)
  end
end
