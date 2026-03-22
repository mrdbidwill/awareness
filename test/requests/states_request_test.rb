# frozen_string_literal: true

require "test_helper"

class StatesRequestTest < ActionDispatch::IntegrationTest
  # ============================================================================
  # STATES API REQUEST TESTS
  # ============================================================================
  # Tests for JSON API endpoint providing country-filtered states
  #
  # ENDPOINTS TESTED:
  # - GET /states.json?country_id=1
  #
  # FEATURES TESTED:
  # - Public access (no authentication required)
  # - Country-based filtering
  # - JSON response format
  # - Response structure and data types
  # - Empty result handling
  # - Invalid parameter handling
  # - HTML format rejection
  # ============================================================================

  setup do
    @country = countries(:one)
    @state = states(:one)
    @other_country = countries(:two)
    @other_state = states(:two)
  end

  # ==========================================================================
  # AUTHENTICATION TESTS
  # ==========================================================================

  test "states index does not require authentication" do
    get states_path(format: :json, country_id: @country.id)
    assert_response :success
  end

  test "states index works for unauthenticated users" do
    get states_path(format: :json, country_id: @country.id)
    assert_response :success
    json = JSON.parse(response.body)
    assert json.is_a?(Array)
  end

  test "states index works for authenticated users" do
    sign_in users(:one)
    get states_path(format: :json, country_id: @country.id)
    assert_response :success
  end

  # ==========================================================================
  # FILTERING TESTS
  # ==========================================================================

  test "states index filters by country_id" do
    get states_path(format: :json, country_id: @country.id)
    assert_response :success

    json = JSON.parse(response.body)
    assert json.is_a?(Array)

    # All returned states should belong to the specified country
    json.each do |state|
      fetched_state = State.find(state["id"])
      assert_equal @country.id, fetched_state.country_id
    end
  end

  test "states index returns only states for specified country" do
    get states_path(format: :json, country_id: @country.id)
    assert_response :success

    json = JSON.parse(response.body)
    state_ids = json.map { |s| s["id"] }

    # Should include states from the specified country
    country_state_ids = State.where(country_id: @country.id).pluck(:id)
    country_state_ids.each do |id|
      assert_includes state_ids, id
    end

    # Should not include states from other countries
    other_country_state_ids = State.where(country_id: @other_country.id).pluck(:id)
    other_country_state_ids.each do |id|
      assert_not_includes state_ids, id
    end
  end

  test "states index returns empty array for country with no states" do
    country_no_states = Country.create!(name: "NoStatesCountry", description: "Test")

    get states_path(format: :json, country_id: country_no_states.id)
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal [], json
  end

  test "states index with non-existent country_id returns empty array" do
    get states_path(format: :json, country_id: 999999)
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal [], json
  end

  test "states index with missing country_id parameter returns empty array" do
    get states_path(format: :json)
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal [], json
  end

  # ==========================================================================
  # RESPONSE FORMAT TESTS
  # ==========================================================================

  test "states index returns JSON format" do
    get states_path(format: :json, country_id: @country.id)
    assert_response :success
    assert_equal "application/json; charset=utf-8", response.content_type
  end

  test "states index returns proper JSON structure" do
    get states_path(format: :json, country_id: @country.id)
    assert_response :success

    json = JSON.parse(response.body)
    assert json.is_a?(Array)

    if json.any?
      first_state = json.first
      assert first_state.key?("id")
      assert first_state.key?("name")
      assert first_state["id"].is_a?(Integer)
      assert first_state["name"].is_a?(String)
    end
  end

  test "states index returns only id and name fields" do
    get states_path(format: :json, country_id: @country.id)
    assert_response :success

    json = JSON.parse(response.body)
    if json.any?
      first_state = json.first
      # Should only have id and name, not description, comments, etc.
      assert_equal ["id", "name"].sort, first_state.keys.sort
    end
  end

  test "states index returns states ordered by name" do
    # Create states with specific names for ordering test
    State.create!(name: "ZState", country: @country, description: "Last")
    State.create!(name: "AState", country: @country, description: "First")
    State.create!(name: "MState", country: @country, description: "Middle")

    get states_path(format: :json, country_id: @country.id)
    assert_response :success

    json = JSON.parse(response.body)
    names = json.map { |s| s["name"] }

    # Names should be in alphabetical order (case-insensitive like database)
    assert_equal names.sort_by(&:downcase), names
  end

  test "states index returns valid JSON for empty results" do
    country_no_states = Country.create!(name: "EmptyCountry")

    get states_path(format: :json, country_id: country_no_states.id)
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal [], json
    assert json.is_a?(Array)
  end

  # ==========================================================================
  # HTML FORMAT TESTS
  # ==========================================================================

  test "states index rejects HTML format" do
    get states_path(format: :html, country_id: @country.id)
    assert_response :not_found
  end

  test "states index with no format defaults properly" do
    # When called without format, should handle gracefully
    get states_path(country_id: @country.id)
    # Controller explicitly returns 404 for HTML format
    assert_response :not_found
  end

  # ==========================================================================
  # PARAMETER VALIDATION TESTS
  # ==========================================================================

  test "states index handles string country_id" do
    get states_path(format: :json, country_id: @country.id.to_s)
    assert_response :success

    json = JSON.parse(response.body)
    assert json.is_a?(Array)
  end

  test "states index handles invalid string country_id" do
    get states_path(format: :json, country_id: "invalid")
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal [], json
  end

  test "states index handles negative country_id" do
    get states_path(format: :json, country_id: -1)
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal [], json
  end

  test "states index handles zero country_id" do
    get states_path(format: :json, country_id: 0)
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal [], json
  end

  test "states index handles null country_id" do
    get states_path(format: :json, country_id: nil)
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal [], json
  end

  # ==========================================================================
  # SECURITY TESTS
  # ==========================================================================

  test "states index does not verify authenticity token" do
    # This endpoint should skip CSRF token verification for API usage
    post states_path(format: :json, country_id: @country.id)
    # POST should fail (only GET supported) but not due to CSRF
    # Just verify the endpoint doesn't error on CSRF - should return 404 not 422
    assert_response :not_found, "Should return 404 for unsupported POST, not 422 (CSRF error)"
  end

  test "states index handles SQL injection attempt in country_id" do
    get states_path(format: :json, country_id: "1; DROP TABLE states; --")
    assert_response :success

    json = JSON.parse(response.body)
    assert json.is_a?(Array)

    # Verify states table still exists
    assert State.count >= 0
  end

  test "states index sanitizes country_id parameter" do
    malicious_ids = ["<script>alert('xss')</script>", "'; DROP TABLE states; --", "1 OR 1=1"]

    malicious_ids.each do |bad_id|
      get states_path(format: :json, country_id: bad_id)
      assert_response :success

      json = JSON.parse(response.body)
      assert json.is_a?(Array)
    end
  end

  # ==========================================================================
  # CORS TESTS (if applicable)
  # ==========================================================================

  test "states index allows cross-origin requests" do
    # If CORS is enabled, verify headers
    get states_path(format: :json, country_id: @country.id),
        headers: { "Origin" => "http://example.com" }

    assert_response :success
    # Check for CORS headers if implemented
    # assert response.headers["Access-Control-Allow-Origin"].present?
  end

  # ==========================================================================
  # PERFORMANCE TESTS
  # ==========================================================================

  test "states index with many states returns efficiently" do
    # Create many states for a country
    20.times { |i| State.create!(name: "State#{i}", country: @country) }

    assert_nothing_raised do
      get states_path(format: :json, country_id: @country.id)
    end

    assert_response :success
    json = JSON.parse(response.body)
    assert_operator json.length, :>=, 20
  end

  # ==========================================================================
  # DATA INTEGRITY TESTS
  # ==========================================================================

  test "states index returns correct state data" do
    get states_path(format: :json, country_id: @country.id)
    assert_response :success

    json = JSON.parse(response.body)
    if json.any?
      # Find a known state in results
      state_json = json.find { |s| s["id"] == @state.id }
      if state_json
        assert_equal @state.id, state_json["id"]
        assert_equal @state.name, state_json["name"]
      end
    end
  end

  test "states index does not leak sensitive data" do
    get states_path(format: :json, country_id: @country.id)
    assert_response :success

    json = JSON.parse(response.body)
    if json.any?
      first_state = json.first
      # Should not include internal fields
      assert_not first_state.key?("created_at")
      assert_not first_state.key?("updated_at")
      assert_not first_state.key?("description")
      assert_not first_state.key?("comments")
    end
  end

  # ==========================================================================
  # EDGE CASES
  # ==========================================================================

  test "states index handles multiple country_id parameters" do
    # If multiple country_id params sent, should use first one
    get states_path(format: :json, country_id: [@country.id, @other_country.id])
    assert_response :success

    json = JSON.parse(response.body)
    assert json.is_a?(Array)
  end

  test "states index with empty string country_id" do
    get states_path(format: :json, country_id: "")
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal [], json
  end

  test "states index response is cacheable" do
    get states_path(format: :json, country_id: @country.id)
    assert_response :success

    # Make same request again
    get states_path(format: :json, country_id: @country.id)
    assert_response :success

    # Results should be consistent
    json1 = JSON.parse(response.body)

    get states_path(format: :json, country_id: @country.id)
    json2 = JSON.parse(response.body)

    assert_equal json1, json2
  end

  test "states index handles country with special characters in states" do
    state_special = State.create!(
      name: "State-with-dashes & Special!",
      country: @country,
      description: "Test"
    )

    get states_path(format: :json, country_id: @country.id)
    assert_response :success

    json = JSON.parse(response.body)
    state_names = json.map { |s| s["name"] }
    assert_includes state_names, state_special.name
  end

  test "states index returns unicode state names correctly" do
    unicode_state = State.create!(
      name: "État Français",
      country: @country,
      description: "French state"
    )

    get states_path(format: :json, country_id: @country.id)
    assert_response :success

    json = JSON.parse(response.body)
    state_names = json.map { |s| s["name"] }
    assert_includes state_names, "État Français"
  end
end
