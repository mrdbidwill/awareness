require "application_system_test_case"

class MrCharactersTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
    @mr_character = mr_characters(:one)
    sign_in @user

    # Use fixture records
    @part = parts(:one)
    @observation_method = observation_methods(:one)
    @display_option = display_options(:one)
    @source_data = SourceData.find_by(title: "Field Guide of Fungi")
  end

  test "visiting the mr_characters index" do
    visit mr_characters_path
    assert_selector "h1", text: "Mushroom Characters"
  end

  test "creating a new Mushroom Character" do
    visit mr_characters_path
    click_on "New Mushroom Character"

    fill_in "Name", with: "New Character Name"
    fill_in "Part", with: @part.id
    fill_in "Observation Method", with: @observation_method.id
    fill_in "Display Option", with: @display_option.id
    fill_in "Source Data", with: @source_data.id
    click_on "Create Mushroom Character"

    assert_text "Mushroom Character was successfully created"
    assert_selector "p", text: "Mushroom Character was successfully created"
  end

  test "editing a Mushroom Character" do
    visit mr_characters_path
    click_on "Edit", match: :first

    fill_in "Name", with: "Updated Mushroom Character Name"
    click_on "Update Mushroom Character"

    assert_text "Mushroom Character was successfully updated"
  end

  test "destroying a Mushroom Character" do
    visit mr_characters_path
    accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Mushroom Character was successfully deleted"
  end
end
