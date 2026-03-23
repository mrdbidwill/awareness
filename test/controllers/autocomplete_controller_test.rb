require "test_helper"

class AutocompleteControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_user = users(:one)
    sign_in @admin_user
  end

  test "genera returns only genus rank entries" do
    MbList.create!(taxon_name: "Ganoderma", rank_name: "gen.", name_status: "Legitimate")
    MbList.create!(taxon_name: "Ganoderma subgen. Haddowia", rank_name: "subgen.", name_status: "Legitimate")
    MbList.create!(taxon_name: "Ganoderma sessile", rank_name: "sp.", name_status: "Legitimate")

    get genera_autocomplete_url, params: { q: "Gano" }, as: :json

    assert_response :success
    names = JSON.parse(response.body).map { |item| item["name"] }
    assert_includes names, "Ganoderma"
    assert_not_includes names, "Ganoderma subgen. Haddowia"
    assert_not_includes names, "Ganoderma sessile"
  end

  test "species filters by genus_name and species rank" do
    MbList.create!(taxon_name: "Ganoderma sessile", rank_name: "sp.", name_status: "Legitimate")
    MbList.create!(taxon_name: "Amanita sessilis", rank_name: "sp.", name_status: "Legitimate")
    MbList.create!(taxon_name: "Ganoderma subgen. Haddowia", rank_name: "subgen.", name_status: "Legitimate")

    get species_autocomplete_url, params: { q: "sessi", genus_name: "Ganoderma" }, as: :json

    assert_response :success
    names = JSON.parse(response.body).map { |item| item["name"] }
    assert_includes names, "Ganoderma sessile"
    assert_not_includes names, "Amanita sessilis"
    assert_not_includes names, "Ganoderma subgen. Haddowia"
  end
end
