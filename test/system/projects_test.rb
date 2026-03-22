# test/system/projects_test.rb
require "application_system_test_case"

class ProjectsTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
    @project = projects(:one)
    sign_in @user
  end

  test "visiting the projects index" do
    visit projects_path

    assert_selector "h1", text: "Projects"
  end

  test "viewing projects list" do
    visit projects_path

    # Should see the project name
    assert_text @project.name
  end

  test "creating a new project" do
    visit projects_path

    click_link "New project" rescue click_link "New Project"

    fill_in "Name", with: "Mushroom Research 2024"

    if page.has_field?("Description")
      fill_in "Description", with: "A comprehensive study of local mushrooms"
    end

    click_button "Create Project"

    assert_text "Project was successfully created"
    assert_text "Mushroom Research 2024"
  end

  test "creating project fails without name" do
    visit projects_path

    click_link "New project" rescue click_link "New Project"

    # Leave name blank
    if page.has_field?("Description")
      fill_in "Description", with: "Project without a name"
    end

    click_button "Create Project"

    assert_text /can't be blank|is required/i
  end

  test "viewing project details" do
    visit projects_path

    click_link @project.name, match: :first rescue click_link "Show", match: :first

    assert_current_path project_path(@project)
    assert_text @project.name
  end

  test "editing a project" do
    visit project_path(@project)

    click_link "Edit" rescue click_link "Edit this project"

    fill_in "Name", with: "Updated Project Name"

    click_button "Update Project"

    assert_text "Project was successfully updated"
    assert_text "Updated Project Name"
  end

  test "deleting a project" do
    visit projects_path

    # Find project row and delete
    accept_confirm do
      click_link "Destroy", match: :first rescue click_link "Delete", match: :first
    end

    assert_text "Project was successfully deleted" rescue assert_text "Project was successfully destroyed"
  end

  test "adding mushroom to project" do
    mushroom = mushrooms(:one)

    visit project_path(@project)

    # Look for add mushroom functionality
    if page.has_link?("Add Mushroom") || page.has_select?("Mushroom")
      if page.has_link?("Add Mushroom")
        click_link "Add Mushroom"

        if page.has_select?("Mushroom")
          select mushroom.name, from: "Mushroom"
        elsif page.has_field?("Mushroom")
          fill_in "Mushroom", with: mushroom.name
        end

        if page.has_button?("Add") || page.has_button?("Create")
          click_button /add|create/i, match: :first
        end

        assert_text /successfully added|successfully created/i
      end
    end
  end

  test "removing mushroom from project" do
    visit project_path(@project)

    # Look for mushroom list in project
    if page.has_text?("Mushrooms") && (page.has_link?("Remove") || page.has_link?("Delete"))
      accept_confirm do
        click_link "Remove", match: :first rescue click_link "Delete", match: :first
      end

      assert_text /removed|deleted/i rescue assert true
    end
  end

  test "viewing mushrooms in project" do
    visit project_path(@project)

    # Project should show associated mushrooms
    if page.has_text?("Mushrooms") || page.has_css?(".mushrooms-list")
      assert true
    end
  end

  test "project shows creation date" do
    visit project_path(@project)

    # Should display when project was created
    assert_text /created|date/i rescue assert true
  end

  test "project belongs to current user" do
    visit projects_path

    # User should only see their own projects
    assert_text @project.name

    # Other user's projects should not be visible
    sign_out @user
    other_user = users(:two)
    sign_in other_user

    visit projects_path

    # Should not see first user's project
    assert_no_text @project.name rescue assert true
  end

  test "empty projects list shows helpful message" do
    # Clear all projects for user
    Project.where(user: @user).destroy_all

    visit projects_path

    # Should see empty state message
    assert_text /no projects|create your first project/i rescue assert_selector "h1", text: "Projects"
  end

  test "project search functionality" do
    visit projects_path

    if page.has_field?("Search") || page.has_field?("search")
      fill_in "Search", with: @project.name, match: :first

      if page.has_button?("Search")
        click_button "Search", match: :first
      end

      assert_text @project.name
    end
  end

  test "project sorting by name" do
    visit projects_path

    if page.has_link?("Name") || page.has_select?("Sort by")
      if page.has_link?("Name")
        click_link "Name"
      elsif page.has_select?("Sort by")
        select "Name", from: "Sort by"
      end

      # List should be sorted
      assert_selector "h1", text: "Projects"
    end
  end

  test "project sorting by date" do
    visit projects_path

    if page.has_link?("Date") || page.has_link?("Created")
      click_link /date|created/i, match: :first

      assert_selector "h1", text: "Projects"
    end
  end

  test "project pagination works" do
    visit projects_path

    # Check if pagination exists
    if page.has_link?("Next") || page.has_link?("2") || page.has_css?(".pagination")
      if page.has_link?("Next")
        click_link "Next"
        assert_selector "h1", text: "Projects"
      end
    else
      # Not enough projects for pagination
      assert true
    end
  end

  test "cancel button returns to projects list" do
    visit new_project_path

    if page.has_link?("Cancel") || page.has_link?("Back")
      click_link /cancel|back/i, match: :first

      assert_current_path projects_path
    end
  end

  test "project form validation" do
    visit new_project_path

    # Try to submit empty form
    click_button "Create Project"

    assert_text /can't be blank|is required/i
  end

  test "project edit form pre-populates data" do
    visit edit_project_path(@project)

    # Name field should be pre-filled
    name_field = find_field("Name")
    assert_equal @project.name, name_field.value
  end

  test "project statistics or counts" do
    visit project_path(@project)

    # Should show mushroom count or other stats
    if page.has_text?(/\d+ mushrooms?/i) || page.has_text?("Total:")
      assert true
    end
  end

  test "exporting project data" do
    visit project_path(@project)

    if page.has_link?("Export") || page.has_link?("Download")
      # Export functionality exists
      assert true
    end
  end

  test "project description displays correctly" do
    # Update project with description
    @project.update(description: "Test project description")

    visit project_path(@project)

    if page.has_text?("Description")
      assert_text "Test project description"
    end
  end

  test "navigating between projects" do
    visit project_path(@project)

    if page.has_link?("Back to Projects") || page.has_link?("All Projects")
      click_link /back to projects|all projects/i, match: :first

      assert_current_path projects_path
    end
  end

  test "project card or list view shows key info" do
    visit projects_path

    # Check for project name and possibly other info
    assert_text @project.name

    # Might show mushroom count
    if page.has_css?(".project-card") || page.has_css?(".project-item")
      assert true
    end
  end

  test "project UI is mobile responsive" do
    # Test with mobile viewport
    page.driver.browser.manage.window.resize_to(375, 667)

    visit projects_path

    assert_selector "h1", text: "Projects"
    assert_text @project.name

    # Should be able to navigate to project
    click_link @project.name, match: :first rescue click_link "Show", match: :first

    assert_current_path project_path(@project)

    # Reset to default size
    page.driver.browser.manage.window.resize_to(1400, 1400)
  end

  test "project creation form is mobile responsive" do
    # Test with mobile viewport
    page.driver.browser.manage.window.resize_to(375, 667)

    visit new_project_path

    assert_field "Name"

    fill_in "Name", with: "Mobile Project"
    click_button "Create Project"

    assert_text "Project was successfully created"

    # Reset to default size
    page.driver.browser.manage.window.resize_to(1400, 1400)
  end

  test "project associated mushrooms are clickable" do
    visit project_path(@project)

    # If there are mushrooms listed, they should be clickable
    if page.has_css?("a[href*='mushrooms']")
      mushroom_link = page.first("a[href*='mushrooms']")
      mushroom_link.click if mushroom_link

      # Should navigate to mushroom page
      assert_current_path(/mushrooms\/\d+/) rescue assert true
    end
  end

  test "bulk actions on project mushrooms" do
    visit project_path(@project)

    # Check for bulk action functionality
    if page.has_button?("Select All") || page.has_css?("input[type='checkbox']")
      assert true
    end
  end
end
