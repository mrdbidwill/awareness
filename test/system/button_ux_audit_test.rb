# test/system/button_ux_audit_test.rb
require "application_system_test_case"

class ButtonUxAuditTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
    sign_in @user

    @original_cache = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
  end

  teardown do
    Rails.cache = @original_cache
  end

  test "primary mushroom and image buttons work end to end" do
    visit mushrooms_path
    visit new_mushroom_path

    fill_in "Name", with: "Audit Button Mushroom"
    select "USA", from: "Country where specimen was found"
    select "Gills", from: "Fungus Type"
    click_button "Create Mushroom"

    assert_text "Mushroom was successfully created"
    assert_selector "h1", text: /new mushroom image/i

    attach_file "Select an Image File", Rails.root.join("test/fixtures/files/test.jpg")
    fill_in "Image Name", with: "Audit Image"
    select "Cap", from: "Mushroom Part"
    click_button "Upload Image"

    assert_text "Image successfully uploaded."

    click_on "Edit - Add Characters"
    fill_in "Name", with: "Audit Button Mushroom Updated"
    click_button "Update name"
    assert_text "Mushroom was successfully updated."

    click_on "Edit - Add Characters"
    click_on "Edit Image", match: :first
    assert_button "Update Image"

    accept_confirm do
      click_button "Delete This Image"
    end
    assert_text "Image was successfully deleted."

    accept_confirm do
      click_button "Delete Mushroom"
    end
    assert_text "Mushroom was successfully deleted."
  end
end
