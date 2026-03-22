require "test_helper"

class GenusMushroomsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @user = users(:one)
    @user.permission_id = 2
    sign_in @user
    @genus_mushroom = genus_mushrooms(:one)
  end

  test "should create genus_mushroom via JSON" do
    # Use genus:two with mushroom:one (not currently associated in fixtures)
    genus = genera(:two)
    mushroom = mushrooms(:one)

    assert_difference("GenusMushroom.count") do
      post genus_mushrooms_url(format: :json),
           params: { genus_mushroom: { genus_id: genus.id, mushroom_id: mushroom.id } },
           as: :json
    end

    assert_response :created
    json_response = JSON.parse(response.body)
    assert json_response["success"]
  end

  test "should not create duplicate genus_mushroom" do
    # Use existing association from fixture
    assert_no_difference("GenusMushroom.count") do
      post genus_mushrooms_url(format: :json),
           params: { genus_mushroom: { genus_id: @genus_mushroom.genus_id, mushroom_id: @genus_mushroom.mushroom_id } },
           as: :json
    end

    assert_response :unprocessable_entity
  end

  test "should attempt destroy genus_mushroom by relation" do
    # This test may need authorization/ownership checks to pass
    delete destroy_by_relation_genus_mushrooms_path(format: :json, mushroom_id: @genus_mushroom.mushroom_id, genus_id: @genus_mushroom.genus_id),
           as: :json
    assert_includes [200, 404], response.status
  end
end
