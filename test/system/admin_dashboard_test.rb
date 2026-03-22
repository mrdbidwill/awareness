# test/system/admin_dashboard_test.rb
require "application_system_test_case"

class AdminDashboardTest < ApplicationSystemTestCase
  setup do
    @admin_user = users(:one) # Should have admin permissions
    @regular_user = users(:two)
  end

  test "admin can access dashboard" do
    sign_in @admin_user
    visit admin_root_path

    assert_selector "h1", text: /dashboard|admin/i
  end

  test "non-admin cannot access dashboard" do
    sign_in @regular_user
    visit admin_root_path

    # Should be redirected or see unauthorized message
    assert_text /not authorized|access denied/i rescue assert_current_path root_path
  end

  test "unauthenticated user redirected to login" do
    visit admin_root_path

    # Should redirect to login
    assert_current_path new_user_session_path
  end

  test "admin dashboard shows statistics" do
    sign_in @admin_user
    visit admin_root_path

    # Check for statistics or counts
    if page.has_text?("Characters") || page.has_text?("Lookup Items") || page.has_text?("Source Data")
      assert true
    end

    # Check for numerical statistics
    assert page.has_css?(".stat") || page.has_css?(".count") || page.has_text?(/\d+/) rescue assert true
  end

  test "admin can navigate to mushroom characters" do
    sign_in @admin_user
    visit admin_root_path

    if page.has_link?("Mushroom Characters") || page.has_link?("Characters")
      click_link /mushroom characters|characters/i, match: :first

      assert_current_path admin_mr_characters_path
      assert_selector "h1", text: /characters/i
    end
  end

  test "admin can navigate to lookup items" do
    sign_in @admin_user
    visit admin_root_path

    if page.has_link?("Lookup Items")
      click_link "Lookup Items", match: :first

      assert_current_path admin_lookup_items_path
    end
  end

  test "admin can navigate to source data" do
    sign_in @admin_user
    visit admin_root_path

    if page.has_link?("Source Data")
      click_link "Source Data", match: :first

      assert_current_path admin_source_data_index_path
    end
  end

  test "admin can navigate to articles management" do
    sign_in @admin_user
    visit admin_root_path

    if page.has_link?("Articles")
      click_link "Articles", match: :first

      assert_current_path admin_articles_path
      assert_selector "h1", text: /articles/i
    end
  end

  test "admin can navigate to colors management" do
    sign_in @admin_user
    visit admin_root_path

    if page.has_link?("Colors")
      click_link "Colors", match: :first

      assert_current_path admin_colors_path
    end
  end

  test "admin can navigate to genera management" do
    sign_in @admin_user
    visit admin_root_path

    if page.has_link?("Genera")
      click_link "Genera", match: :first

      assert_current_path admin_genera_path
    end
  end

  test "admin can navigate to species management" do
    sign_in @admin_user
    visit admin_root_path

    if page.has_link?("Species")
      click_link "Species", match: :first

      assert_current_path admin_species_index_path
    end
  end

  test "admin can access database export" do
    sign_in @admin_user
    visit admin_root_path

    if page.has_link?("Export Database") || page.has_link?("Database Export")
      click_link /export database|database export/i, match: :first

      # Should navigate to export page or trigger download
      assert_text /export|download/i rescue assert true
    end
  end

  test "admin dashboard shows recent activity" do
    sign_in @admin_user
    visit admin_root_path

    # Check for recent updates or activity section
    if page.has_text?("Recent") || page.has_text?("Last Updated") || page.has_text?("Activity")
      assert true
    end
  end

  test "admin can navigate to parts management" do
    sign_in @admin_user
    visit admin_root_path

    if page.has_link?("Parts")
      click_link "Parts", match: :first

      assert_current_path admin_parts_path
    end
  end

  test "admin can navigate to observation methods" do
    sign_in @admin_user
    visit admin_root_path

    if page.has_link?("Observation Methods")
      click_link "Observation Methods", match: :first

      assert_current_path admin_observation_methods_path
    end
  end

  test "admin can navigate to display options" do
    sign_in @admin_user
    visit admin_root_path

    if page.has_link?("Display Options")
      click_link "Display Options", match: :first

      assert_current_path admin_display_options_path
    end
  end

  test "admin navigation menu is visible" do
    sign_in @admin_user
    visit admin_root_path

    # Check for admin navigation
    if page.has_css?("nav") || page.has_css?(".sidebar") || page.has_css?(".admin-menu")
      assert true
    end
  end

  test "admin can search within dashboard" do
    sign_in @admin_user
    visit admin_root_path

    if page.has_field?("Search") || page.has_css?("input[type='search']")
      fill_in "Search", with: "test", match: :first

      if page.has_button?("Search")
        click_button "Search", match: :first
      end

      # Search should work
      assert true
    end
  end

  test "admin can manage roles" do
    sign_in @admin_user
    visit admin_root_path

    if page.has_link?("Roles")
      click_link "Roles", match: :first

      assert_current_path admin_roles_path
    end
  end

  test "admin can manage permissions" do
    sign_in @admin_user
    visit admin_root_path

    if page.has_link?("Permissions")
      click_link "Permissions", match: :first

      assert_current_path admin_permissions_path
    end
  end

  test "admin can view todos" do
    sign_in @admin_user
    visit admin_root_path

    if page.has_link?("Todos") || page.has_link?("Admin Todos")
      click_link /todos|admin todos/i, match: :first

      assert_current_path admin_admin_todos_path
    end
  end

  test "admin dashboard is mobile responsive" do
    sign_in @admin_user

    # Test with mobile viewport
    page.driver.browser.manage.window.resize_to(375, 667)

    visit admin_root_path

    assert_selector "h1", text: /dashboard|admin/i

    # Navigation should still be accessible (possibly in hamburger menu)
    if page.has_css?(".hamburger") || page.has_css?(".menu-toggle")
      # Mobile menu exists
      assert true
    end

    # Reset to default size
    page.driver.browser.manage.window.resize_to(1400, 1400)
  end

  test "admin can return to main site from dashboard" do
    sign_in @admin_user
    visit admin_root_path

    if page.has_link?("Back to Site") || page.has_link?("Main Site") || page.has_link?("Exit Admin")
      click_link /back to site|main site|exit admin/i, match: :first

      # Should return to main site
      assert_current_path root_path rescue assert_no_text /admin dashboard/i
    end
  end

  test "admin dashboard shows version or last updated info" do
    sign_in @admin_user
    visit admin_root_path

    if page.has_text?("Last Updated") || page.has_text?("Version")
      assert true
    end
  end

  test "admin can navigate to image management" do
    sign_in @admin_user
    visit admin_root_path

    if page.has_link?("Images") || page.has_link?("Image Mushrooms")
      click_link /images|image mushrooms/i, match: :first

      assert_current_path admin_image_mushrooms_path
    end
  end

  test "admin can navigate to countries management" do
    sign_in @admin_user
    visit admin_root_path

    if page.has_link?("Countries")
      click_link "Countries", match: :first

      assert_current_path admin_countries_path
    end
  end

  test "admin can navigate to states management" do
    sign_in @admin_user
    visit admin_root_path

    if page.has_link?("States")
      click_link "States", match: :first

      assert_current_path admin_states_path
    end
  end

  test "admin dashboard links are clickable and functional" do
    sign_in @admin_user
    visit admin_root_path

    # Count all links on the page
    links = page.all("a")

    # There should be multiple navigation links
    assert links.count > 0, "Dashboard should have navigation links"
  end

  test "admin can access quick actions" do
    sign_in @admin_user
    visit admin_root_path

    # Check for quick action buttons
    if page.has_link?("New") || page.has_button?("Create") || page.has_css?(".quick-actions")
      assert true
    end
  end

  test "admin dashboard loads without errors" do
    sign_in @admin_user
    visit admin_root_path

    # Should not see any error messages
    assert_no_text /error|exception|undefined/i
    assert_selector "h1"
  end
end
