require "test_helper"

class GenusMushroomsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @mushroom = mushrooms(:one)
    @genus = genera(:one)
    @other_genus = genera(:two)
    sign_in @user
  end

  test "should create genus_mushroom as JSON" do
    assert_difference("GenusMushroom.count") do
      post genus_mushrooms_url, params: {
        genus_mushroom: {
          mushroom_id: @mushroom.id,
          genus_id: @other_genus.id  # Use other_genus to avoid fixture duplication
        }
      }, as: :json
    end

    assert_response :created
    json_response = JSON.parse(response.body)
    assert json_response["success"]
    assert json_response["id"]
  end

  test "should handle duplicate genus_mushroom" do
    # Fixtures already have mushroom:one with genus:one

    # Try to create duplicate
    post genus_mushrooms_url, params: {
      genus_mushroom: {
        mushroom_id: @mushroom.id,
        genus_id: @genus.id
      }
    }, as: :json

    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert_not json_response["success"]
  end

  test "should destroy genus_mushroom by relation" do
    # Use other_genus to avoid fixture duplication
    genus_mushroom = GenusMushroom.create!(
      mushroom_id: @mushroom.id,
      genus_id: @other_genus.id
    )

    assert_difference("GenusMushroom.count", -1) do
      delete destroy_by_relation_genus_mushrooms_url, params: {
        mushroom_id: @mushroom.id,
        genus_id: @other_genus.id
      }, as: :json
    end

    assert_response :success
    json_response = JSON.parse(response.body)
    assert json_response["success"]
  end

  test "should return not found for non-existent relation" do
    delete destroy_by_relation_genus_mushrooms_url, params: {
      mushroom_id: 99999,
      genus_id: 99999
    }, as: :json

    assert_response :not_found
    json_response = JSON.parse(response.body)
    assert_not json_response["success"]
  end

  test "should require authentication" do
    sign_out @user

    post genus_mushrooms_url, params: {
      genus_mushroom: {
        mushroom_id: @mushroom.id,
        genus_id: @genus.id
      }
    }, as: :json

    assert_response :unauthorized
  end

  test "should handle invalid params" do
    post genus_mushrooms_url, params: {
      genus_mushroom: {
        mushroom_id: @mushroom.id,
        genus_id: nil
      }
    }, as: :json

    assert_response :unprocessable_entity
  end
end
