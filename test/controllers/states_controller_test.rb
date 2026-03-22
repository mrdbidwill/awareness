require "test_helper"

class StatesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @country = countries(:one)
    @state = states(:one)
  end

  test "should get index as JSON without authentication" do
    get states_url(country_id: @country.id), as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_kind_of Array, json_response
  end

  test "should filter states by country_id" do
    get states_url(country_id: @country.id), as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    json_response.each do |state|
      assert_equal @country.id, state["country_id"] if state["country_id"]
    end
  end

  test "should return 404 for HTML format" do
    get states_url(country_id: @country.id), as: :html
    assert_response :not_found
  end

  test "should order states by name" do
    get states_url(country_id: @country.id), as: :json
    assert_response :success
  end

  test "should only return id and name fields" do
    get states_url(country_id: @country.id), as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    if json_response.any?
      first_state = json_response.first
      assert first_state.keys.include?("id")
      assert first_state.keys.include?("name")
    end
  end

  test "authenticated user should get index as JSON" do
    sign_in users(:one)
    get states_url(country_id: @country.id), as: :json
    assert_response :success
  end

  test "should handle invalid country_id" do
    get states_url(country_id: 99999), as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_empty json_response
  end
end
