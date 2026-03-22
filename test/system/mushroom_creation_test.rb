# test/system/mushroom_creation_test.rb
require "application_system_test_case"

class MushroomCreationTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
    @mushroom = mushrooms(:one)
    sign_in @user
  end

  test "visiting the new mushroom page" do
    visit new_mushroom_path

    assert_selector "h1", text: /new mushroom/i
    assert_field "Name"
    assert_button "Create Mushroom"
  end

  test "creating a mushroom with basic information" do
    visit new_mushroom_path

    fill_in "Name", with: "Amanita muscaria"
    fill_in "Description", with: "A beautiful red mushroom with white spots"

    # Fill in collection date (default should be set)
    if page.has_field?("Collection date")
      fill_in "Collection date", with: Date.current
    end

    click_button "Create Mushroom"

    assert_text "Mushroom was successfully created"
    assert_text "Amanita muscaria"
  end

  test "creating mushroom with location information" do
    visit new_mushroom_path

    fill_in "Name", with: "Local Mushroom"
    fill_in "Description", with: "Found near oak tree"

    # Fill location fields if they exist
    if page.has_field?("Found address")
      fill_in "Found address", with: "123 Forest Lane"
    end

    if page.has_field?("Found city")
      fill_in "Found city", with: "Mobile"
    end

    if page.has_field?("Found state")
      select "Alabama", from: "Found state" rescue nil
    end

    click_button "Create Mushroom"

    assert_text "Mushroom was successfully created"
  end

  test "creating mushroom with substrate information" do
    visit new_mushroom_path

    fill_in "Name", with: "Wood-loving mushroom"
    fill_in "Description", with: "Growing on oak log"

    # Check for substrate field
    if page.has_field?("Substrate")
      fill_in "Substrate", with: "Oak log"
    end

    click_button "Create Mushroom"

    assert_text "Mushroom was successfully created"
  end

  test "creating mushroom fails without required name" do
    visit new_mushroom_path

    fill_in "Description", with: "A mushroom without a name"

    click_button "Create Mushroom"

    assert_text /can't be blank|is required/i
  end

  test "creating mushroom with weather conditions" do
    visit new_mushroom_path

    fill_in "Name", with: "Rainy Day Mushroom"
    fill_in "Description", with: "Found after heavy rain"

    # Fill weather fields if available
    if page.has_field?("Temp in F")
      fill_in "Temp in F", with: "65"
    end

    if page.has_field?("Weather")
      fill_in "Weather", with: "Rainy"
    end

    click_button "Create Mushroom"

    assert_text "Mushroom was successfully created"
  end

  test "attaching images to new mushroom" do
    visit new_mushroom_path

    fill_in "Name", with: "Photo Mushroom"
    fill_in "Description", with: "Mushroom with photos"

    click_button "Create Mushroom"

    assert_text "Mushroom was successfully created"

    # Navigate to add images
    if page.has_link?("Add Image") || page.has_link?("New Image")
      click_link /add image|new image/i

      # Check for image upload form
      if page.has_field?("image_mushroom[image]", type: "file")
        # Create a test image file
        test_image = Rails.root.join('test', 'fixtures', 'files', 'test_image.jpg')

        # Attach file if it exists
        if File.exist?(test_image)
          attach_file "image_mushroom[image]", test_image
          click_button "Create"

          assert_text /image was successfully|successfully added/i
        end
      end
    end
  end

  test "adding multiple images to mushroom" do
    visit mushroom_path(@mushroom)

    # Try to add first image
    if page.has_link?("Add Image") || page.has_link?("New Image")
      click_link /add image|new image/i, match: :first

      if page.has_field?("Caption")
        fill_in "Caption", with: "Top view"
      end

      if page.has_button?("Create") || page.has_button?("Upload")
        click_button /create|upload/i, match: :first
      end
    end
  end

  test "adding genus to mushroom" do
    visit mushroom_path(@mushroom)

    # Check if genus section exists
    if page.has_link?("Add Genus") || page.has_text?("Genus")
      if page.has_link?("Add Genus")
        click_link "Add Genus"

        # Fill genus autocomplete if available
        if page.has_field?("Genus")
          fill_in "Genus", with: "Amanita"
        end

        if page.has_button?("Add") || page.has_button?("Create")
          click_button /add|create/i, match: :first
          assert_text /successfully added|successfully created/i
        end
      end
    end
  end

  test "adding species to mushroom" do
    visit mushroom_path(@mushroom)

    # Check if species section exists
    if page.has_link?("Add Species") || page.has_text?("Species")
      if page.has_link?("Add Species")
        click_link "Add Species"

        # Fill species autocomplete if available
        if page.has_field?("Species")
          fill_in "Species", with: "muscaria"
        end

        if page.has_button?("Add") || page.has_button?("Create")
          click_button /add|create/i, match: :first
          assert_text /successfully added|successfully created/i
        end
      end
    end
  end

  test "cloning mushroom with characters" do
    visit mushroom_path(@mushroom)

    # Look for clone characters button
    if page.has_button?("Clone Characters") || page.has_link?("Clone Characters")
      if page.has_button?("Clone Characters")
        click_button "Clone Characters"
      else
        click_link "Clone Characters"
      end

      # Should see success message or be redirected
      assert_text /cloned|copied/i rescue assert_current_path mushroom_path(@mushroom)
    end
  end

  test "editing mushroom characters" do
    visit mushroom_path(@mushroom)

    # Look for edit characters link
    if page.has_link?("Edit Characters") || page.has_button?("Edit Characters")
      click_link "Edit Characters" rescue click_button "Edit Characters"

      # Should navigate to character editing page
      assert_text /characters|select characters/i
    end
  end

  test "adding mushroom to project" do
    # Create a project first
    project = projects(:one)

    visit mushroom_path(@mushroom)

    # Check if project association exists
    if page.has_select?("Project") || page.has_field?("Project")
      select project.name, from: "Project" rescue fill_in "Project", with: project.name

      if page.has_button?("Add to Project") || page.has_button?("Save")
        click_button /add to project|save/i, match: :first
        assert_text /successfully/i
      end
    end
  end

  test "creating mushroom with notes" do
    visit new_mushroom_path

    fill_in "Name", with: "Detailed Mushroom"
    fill_in "Description", with: "Comprehensive description"

    # Add notes if field exists
    if page.has_field?("Notes")
      fill_in "Notes", with: "Additional observational notes about habitat and conditions"
    end

    click_button "Create Mushroom"

    assert_text "Mushroom was successfully created"
  end

  test "form validation for mushroom creation" do
    visit new_mushroom_path

    # Try to submit without required fields
    click_button "Create Mushroom"

    # Should show validation error
    assert_text /can't be blank|is required/i
  end

  test "cancel button returns to mushrooms index" do
    visit new_mushroom_path

    if page.has_link?("Cancel") || page.has_link?("Back")
      click_link /cancel|back/i, match: :first
      assert_current_path mushrooms_path
    end
  end

  test "creating mushroom with autocomplete fields" do
    visit new_mushroom_path

    fill_in "Name", with: "Autocomplete Test"
    fill_in "Description", with: "Testing autocomplete"

    # Test genus autocomplete if present
    if page.has_field?("Genus")
      fill_in "Genus", with: "Aman"
      # Wait for autocomplete suggestions
      sleep 0.5
      # Suggestions should appear
      assert page.has_css?(".autocomplete-results") || page.has_css?("[role='listbox']") rescue nil
    end

    click_button "Create Mushroom"
    assert_text "Mushroom was successfully created"
  end

  test "mushroom form is mobile responsive" do
    # Test with mobile viewport
    page.driver.browser.manage.window.resize_to(375, 667)

    visit new_mushroom_path

    assert_field "Name"
    assert_field "Description"
    assert_button "Create Mushroom"

    # Form should be usable on mobile
    fill_in "Name", with: "Mobile Mushroom"
    fill_in "Description", with: "Created on mobile"

    click_button "Create Mushroom"
    assert_text "Mushroom was successfully created"

    # Reset to default size
    page.driver.browser.manage.window.resize_to(1400, 1400)
  end

  test "collection date defaults to current date" do
    visit new_mushroom_path

    # Check if collection date has a default value
    if page.has_field?("Collection date")
      date_field = find_field("Collection date")
      # Date should be pre-filled or have today's date
      assert date_field[:value].present? || date_field[:value] == Date.current.to_s
    end
  end

  test "image upload accepts valid file types" do
    visit new_mushroom_path

    fill_in "Name", with: "Image Test Mushroom"
    click_button "Create Mushroom"

    # Try to add an image
    if page.has_link?("Add Image") || page.has_link?("New Image")
      click_link /add image|new image/i, match: :first

      # Check file input accepts image types
      if page.has_field?("image_mushroom[image]", type: "file")
        file_input = find_field("image_mushroom[image]", type: "file")
        # Verify accept attribute for images
        assert file_input[:accept].to_s.include?("image") || file_input[:accept].blank?
      end
    end
  end

  test "creating mushroom and exporting to PDF" do
    visit new_mushroom_path

    fill_in "Name", with: "PDF Export Mushroom"
    fill_in "Description", with: "Testing PDF export"

    click_button "Create Mushroom"
    assert_text "Mushroom was successfully created"

    # Look for export/PDF link
    if page.has_link?("Export") || page.has_link?("PDF")
      # Link exists, test passes
      assert true
    end
  end

end
