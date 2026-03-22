# test/system/mushrooms_test.rb
require "application_system_test_case"

class MushroomsTest < ApplicationSystemTestCase
  setup do
    @user = users(:one) # Reference a user from your fixture
    @mushroom = mushrooms(:one) # Reference a mushroom from your fixture
    sign_in @user
  end

  test "visiting the mushrooms index" do
    visit mushrooms_path
    assert_selector "h1", text: "Mushrooms"
  end

  test "creating a mushroom" do
    visit mushrooms_path
    click_on "New mushroom"

    fill_in "Name", with: "New Mushroom"
    fill_in "Description", with: "Detailed description for the new mushroom"
    fill_in "Collection date", with: 3.days.ago.to_date
    click_on "Create Mushroom"

    assert_text "Mushroom was successfully created"
    # assert_selector "td", text: "New Mushroom"
  end

  test "editing a mushroom" do
    visit mushrooms_path
    click_on "Edit", match: :first

    fill_in "Name", with: "Updated Mushroom Name"
    click_on "Update Mushroom"

    assert_text "Mushroom was successfully updated"
  end

  test "deleting a mushroom" do
    visit mushrooms_path
    accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Mushroom was successfully deleted"
  end
end
