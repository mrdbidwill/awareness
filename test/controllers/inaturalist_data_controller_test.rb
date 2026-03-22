require "test_helper"

class InaturalistDataControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:one)
    @field1 = InaturalistObservationField.create!(
      inaturalist_id: 1,
      name: "Mushroom Cap Color",
      datatype: "text",
      description: "Color of the mushroom cap",
      allowed_values: "red|brown|white|yellow"
    )
    @field2 = InaturalistObservationField.create!(
      inaturalist_id: 2,
      name: "Spore Print Color",
      datatype: "text",
      description: "Color of spore print",
      allowed_values: "white|brown|black"
    )
  end

  test "should get index" do
    get inaturalist_observation_fields_path
    assert_response :success
    assert_select "h1", "iNaturalist Observation Fields"
  end

  test "index should show observation fields" do
    get inaturalist_observation_fields_path
    assert_response :success
    assert_match @field1.name, response.body
    assert_match @field2.name, response.body
  end

  test "index should search by query" do
    get inaturalist_observation_fields_path, params: { q: "mushroom" }
    assert_response :success
    assert_match @field1.name, response.body
    assert_no_match @field2.name, response.body
  end

  test "index should search by description" do
    get inaturalist_observation_fields_path, params: { q: "spore" }
    assert_response :success
    assert_match @field2.name, response.body
    assert_no_match @field1.name, response.body
  end

  test "should download CSV" do
    # Create the CSV file first
    csv_path = Rails.root.join('tmp', 'inaturalist_observation_fields.csv')
    File.write(csv_path, "id,name\n1,Test\n")

    get download_inaturalist_csv_path
    assert_response :success
    assert_equal 'text/csv', response.content_type
    assert_match 'attachment', response.headers['Content-Disposition']

    # Clean up
    File.delete(csv_path) if File.exist?(csv_path)
  end

  test "should generate JSON download" do
    get download_inaturalist_json_path
    assert_response :success
    assert_equal 'application/json', response.content_type
    assert_match 'attachment', response.headers['Content-Disposition']

    # Verify JSON contains field data
    json_data = JSON.parse(response.body)
    assert json_data.is_a?(Array)
    assert json_data.any? { |f| f['name'] == @field1.name }
  end
end
