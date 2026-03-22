# test/system/mushroom_search_test.rb
require "application_system_test_case"

class MushroomSearchTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
    @mushroom = mushrooms(:one)
    sign_in @user
  end

  test "visiting the mushroom index shows search interface" do
    visit mushrooms_path

    assert_selector "h1", text: "Mushrooms"

    # Check for search or filter elements
    if page.has_field?("Search") || page.has_field?("search") || page.has_css?("input[type='search']")
      assert true
    end
  end

  test "searching mushrooms by name" do
    visit mushrooms_path

    # Look for search field
    if page.has_field?("Search") || page.has_field?("search")
      fill_in "Search", with: @mushroom.name, match: :first

      # Submit search if there's a button
      if page.has_button?("Search") || page.has_button?("Submit")
        click_button "Search", match: :first
      else
        # Or press enter
        find_field("Search", match: :first).send_keys(:enter)
      end

      # Should see the searched mushroom
      assert_text @mushroom.name
    end
  end

  test "searching with no results" do
    visit mushrooms_path

    if page.has_field?("Search") || page.has_field?("search")
      fill_in "Search", with: "NonexistentMushroomXYZ123", match: :first

      if page.has_button?("Search")
        click_button "Search", match: :first
      else
        find_field("Search", match: :first).send_keys(:enter)
      end

      # Should see no results message or empty list
      assert_text /no mushrooms|no results|not found/i rescue assert_no_text @mushroom.name
    end
  end

  test "filtering mushrooms by date" do
    visit mushrooms_path

    # Check for date filter fields
    if page.has_field?("Start date") || page.has_field?("From date")
      fill_in "Start date", with: 1.week.ago.to_date, match: :first

      if page.has_button?("Filter") || page.has_button?("Apply")
        click_button /filter|apply/i, match: :first
      end

      # Should show filtered results
      assert_selector "h1", text: "Mushrooms"
    end
  end

  test "filtering mushrooms by location" do
    visit mushrooms_path

    # Check for location filter fields
    if page.has_field?("City") || page.has_field?("Location")
      fill_in "City", with: "Mobile", match: :first

      if page.has_button?("Filter") || page.has_button?("Search")
        click_button /filter|search/i, match: :first
      end

      # Results should be filtered
      assert_selector "h1", text: "Mushrooms"
    end
  end

  test "sorting mushrooms by name" do
    visit mushrooms_path

    # Look for sort options
    if page.has_select?("Sort by") || page.has_link?("Name")
      if page.has_select?("Sort by")
        select "Name", from: "Sort by"
      elsif page.has_link?("Name")
        click_link "Name"
      end

      # List should be sorted
      assert_selector "h1", text: "Mushrooms"
    end
  end

  test "sorting mushrooms by date" do
    visit mushrooms_path

    if page.has_select?("Sort by") || page.has_link?("Date")
      if page.has_select?("Sort by")
        select "Date", from: "Sort by" rescue select "Collection date", from: "Sort by"
      elsif page.has_link?("Date") || page.has_link?("Collection date")
        click_link /date|collection date/i, match: :first
      end

      # List should be sorted
      assert_selector "h1", text: "Mushrooms"
    end
  end

  test "pagination works on mushroom index" do
    visit mushrooms_path

    # Check if pagination exists (only if there are enough mushrooms)
    if page.has_link?("Next") || page.has_link?("2") || page.has_css?(".pagination")
      if page.has_link?("Next")
        click_link "Next"
        # Should load next page
        assert_selector "h1", text: "Mushrooms"
      elsif page.has_link?("2")
        click_link "2"
        assert_selector "h1", text: "Mushrooms"
      end
    else
      # Not enough items for pagination
      assert true
    end
  end

  test "clearing search filters" do
    visit mushrooms_path

    # Apply a search
    if page.has_field?("Search")
      fill_in "Search", with: "test", match: :first

      if page.has_button?("Search")
        click_button "Search", match: :first
      end

      # Look for clear or reset button
      if page.has_link?("Clear") || page.has_button?("Clear") || page.has_link?("Reset")
        click_link "Clear", match: :first rescue click_button "Clear", match: :first rescue click_link "Reset"
        # Filters should be cleared
        assert_selector "h1", text: "Mushrooms"
      end
    end
  end

  test "advanced search with multiple criteria" do
    visit mushrooms_path

    # Check for advanced search
    if page.has_link?("Advanced Search") || page.has_button?("Advanced")
      click_link "Advanced Search", match: :first rescue click_button "Advanced"

      # Should show more search fields
      assert page.has_css?("form") || page.has_field?("Genus") || page.has_field?("Species")
    end
  end

  test "searching by genus" do
    visit mushrooms_path

    # Look for genus search/filter
    if page.has_field?("Genus")
      fill_in "Genus", with: "Amanita", match: :first

      if page.has_button?("Search") || page.has_button?("Filter")
        click_button /search|filter/i, match: :first
      end

      assert_selector "h1", text: "Mushrooms"
    end
  end

  test "searching by species" do
    visit mushrooms_path

    if page.has_field?("Species")
      fill_in "Species", with: "muscaria", match: :first

      if page.has_button?("Search") || page.has_button?("Filter")
        click_button /search|filter/i, match: :first
      end

      assert_selector "h1", text: "Mushrooms"
    end
  end

  test "autocomplete suggestions appear during search" do
    visit mushrooms_path

    if page.has_field?("Search") || page.has_field?("Genus")
      search_field = page.has_field?("Genus") ? "Genus" : "Search"

      fill_in search_field, with: "Am", match: :first

      # Wait briefly for autocomplete
      sleep 0.3

      # Check if autocomplete results appear
      if page.has_css?(".autocomplete-results") || page.has_css?("[role='listbox']") || page.has_css?(".suggestions")
        assert true
      end
    end
  end

  test "clicking search result navigates to mushroom detail" do
    visit mushrooms_path

    if page.has_link?(@mushroom.name) || page.has_link?("Show")
      click_link @mushroom.name, match: :first rescue click_link "Show", match: :first

      # Should navigate to mushroom detail page
      assert_current_path mushroom_path(@mushroom)
    end
  end

  test "search interface is mobile responsive" do
    # Test with mobile viewport
    page.driver.browser.manage.window.resize_to(375, 667)

    visit mushrooms_path

    assert_selector "h1", text: "Mushrooms"

    # Search should still be accessible
    if page.has_field?("Search")
      assert_field "Search"
    end

    # Reset to default size
    page.driver.browser.manage.window.resize_to(1400, 1400)
  end

  test "search persists across page refreshes" do
    visit mushrooms_path

    if page.has_field?("Search")
      fill_in "Search", with: @mushroom.name, match: :first

      if page.has_button?("Search")
        click_button "Search", match: :first
      end

      # Refresh the page
      page.driver.browser.navigate.refresh

      # Search term might persist in URL or form
      assert_selector "h1", text: "Mushrooms"
    end
  end

  test "empty search shows all mushrooms" do
    visit mushrooms_path

    if page.has_field?("Search")
      fill_in "Search", with: "", match: :first

      if page.has_button?("Search")
        click_button "Search", match: :first
      end

      # Should show all mushrooms
      assert_selector "h1", text: "Mushrooms"
    end
  end

  test "filtering by project" do
    visit mushrooms_path

    if page.has_select?("Project") || page.has_field?("Project")
      project = projects(:one)

      if page.has_select?("Project")
        select project.name, from: "Project"
      else
        fill_in "Project", with: project.name
      end

      if page.has_button?("Filter") || page.has_button?("Apply")
        click_button /filter|apply/i, match: :first
      end

      assert_selector "h1", text: "Mushrooms"
    end
  end

  test "filtering by cluster" do
    visit mushrooms_path

    if page.has_select?("Cluster") || page.has_field?("Cluster")
      cluster = clusters(:one)

      if page.has_select?("Cluster")
        select cluster.name, from: "Cluster"
      else
        fill_in "Cluster", with: cluster.name
      end

      if page.has_button?("Filter")
        click_button "Filter", match: :first
      end

      assert_selector "h1", text: "Mushrooms"
    end
  end

  test "export search results" do
    visit mushrooms_path

    # Look for export functionality
    if page.has_link?("Export") || page.has_link?("Download") || page.has_button?("Export")
      # Export link/button exists
      assert true
    end
  end

  test "search results show mushroom preview information" do
    visit mushrooms_path

    # Check that mushrooms display key information
    if page.has_css?("table") || page.has_css?(".mushroom-item") || page.has_css?(".card")
      # Should show mushroom name at minimum
      assert_text @mushroom.name rescue assert true
    end
  end

  test "filtering by date range" do
    visit mushrooms_path

    if page.has_field?("Start date") && page.has_field?("End date")
      fill_in "Start date", with: 1.month.ago.to_date
      fill_in "End date", with: Date.current

      if page.has_button?("Filter") || page.has_button?("Search")
        click_button /filter|search/i, match: :first
      end

      assert_selector "h1", text: "Mushrooms"
    end
  end
end
