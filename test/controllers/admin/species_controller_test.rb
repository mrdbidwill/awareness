require "test_helper"

class SpeciesControllerTest < ActionDispatch::IntegrationTest

  setup do
    @user = users(:one) # Reference your user fixture
    @user.permission_id = 2 # Set admin permission
    @species = species(:one) # Reference your species fixture
    sign_in @user # Devise helper to sign in the user
  end


  test "should get index" do
    get admin_species_index_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_species_url
    assert_response :success
  end

  test "should create species" do
    genus = genera(:one)
    assert_difference("Species.count") do
      post admin_species_index_url, params: { species: { name: "New Species", mblist_id: 999, genera_id: genus.id } }
    end

    assert_redirected_to admin_species_url(Species.last)
  end

  test "should show species" do
    get admin_species_url(@species)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_species_url(@species)
    assert_response :success
  end

  test "should update species" do
    patch admin_species_url(@species), params: { species: { name: @species.name, mblist_id: @species.mblist_id, genera_id: @species.genera_id } }
    assert_redirected_to admin_species_url(@species)
  end

  test "should destroy species" do
    assert_difference("Species.count", -1) do
      delete admin_species_url(@species)
    end

    assert_redirected_to admin_species_index_url
  end
end
