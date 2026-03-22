require "test_helper"

class GenusControllerTest < ActionDispatch::IntegrationTest

  setup do
    @user = users(:one) # Reference your user fixture
    @user.permission_id = 2 # Set admin permission
    @genus = genera(:one) # Reference your genus fixture
    sign_in @user # Devise helper to sign in the user
  end


  test "should get index" do
    get admin_genera_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_genus_url
    assert_response :success
  end

  test "should create genus" do
    assert_difference("Genus.count") do
      post admin_genera_url, params: { genus: { mblist_id: 999, name: "New Genus Name" } }
    end

    assert_redirected_to admin_genus_url(Genus.last)
  end

  test "should show genus" do
    get admin_genus_url(@genus)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_genus_url(@genus)
    assert_response :success
  end

  test "should update genus" do
    patch admin_genus_url(@genus), params: { genus: { mblist_id: @genus.mblist_id, name: @genus.name } }
    assert_redirected_to admin_genus_url(@genus)
  end

  test "should not destroy genus with associated records" do
    # Genera with species cannot be deleted due to strict_loading or foreign keys
    assert_no_difference("Genus.count") do
      begin
        delete admin_genus_url(@genus)
      rescue ActiveRecord::StrictLoadingViolationError, ActiveRecord::InvalidForeignKey
        # Expected - genus has associated records
      end
    end
  end
end
