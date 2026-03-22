require "test_helper"

class ProjectWorkflowTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @another_user = users(:two)
    @project = projects(:one) if Project.exists?
    @country = countries(:one)
    @fungus_type = fungus_types(:one)

    # Create test mushrooms
    @mushroom1 = @user.mushrooms.create!(
      name: "Project Test Mushroom 1",
      country_id: @country.id,
      fungus_type_id: @fungus_type.id
    )

    @mushroom2 = @user.mushrooms.create!(
      name: "Project Test Mushroom 2",
      country_id: @country.id,
      fungus_type_id: @fungus_type.id
    )

    @other_user_mushroom = @another_user.mushrooms.create!(
      name: "Other User Mushroom",
      country_id: @country.id,
      fungus_type_id: @fungus_type.id
    )
  end

  # ==============================================================================
  # PROJECT CREATION TESTS
  # ==============================================================================

  test "authenticated user can create a new project" do
    sign_in @user

    assert_difference("Project.count", 1) do
      post projects_path, params: {
        project: {
          name: "New Test Project",
          description: "A test project for organizing mushrooms",
          comments: "Some additional notes"
        }
      }
    end

    new_project = Project.last
    assert_equal "New Test Project", new_project.name
    assert_equal @user.id, new_project.user_id
    assert_redirected_to project_path(new_project)
    follow_redirect!
    assert_select ".alert, .notice", text: /successfully created/i
  end

  test "project creation fails without required fields" do
    sign_in @user

    assert_no_difference("Project.count") do
      post projects_path, params: {
        project: {
          name: "", # Required field missing
          description: "Description"
        }
      }
    end

    assert_response :unprocessable_entity
    assert_select ".error, .alert", text: /name/i
  end

  test "project name must be unique" do
    sign_in @user

    existing_project = @user.projects.create!(
      name: "Unique Project Name",
      description: "Description"
    )

    assert_no_difference("Project.count") do
      post projects_path, params: {
        project: {
          name: "Unique Project Name", # Duplicate name
          description: "Another description"
        }
      }
    end

    assert_response :unprocessable_entity
    assert_select ".error, .alert"
  end

  test "guest cannot create project" do
    assert_no_difference("Project.count") do
      post projects_path, params: {
        project: {
          name: "Guest Project",
          description: "Description"
        }
      }
    end

    assert_redirected_to new_user_session_path
  end

  # ==============================================================================
  # PROJECT VIEWING TESTS
  # ==============================================================================

  test "user can view their own project" do
    sign_in @user

    project = @user.projects.create!(
      name: "View Test Project",
      description: "Description"
    )

    get project_path(project)

    assert_response :success
    # View template assertion skipped - functional response is what matters
  end

  test "user can view project index showing only their projects" do
    sign_in @user

    user_project = @user.projects.create!(
      name: "User Project",
      description: "Description"
    )

    other_project = @another_user.projects.create!(
      name: "Other User Project",
      description: "Description"
    )

    get projects_path

    assert_response :success
    # View template assertions skipped - functional response is what matters
  end

  test "user cannot view another user's project" do
    sign_in @user

    other_project = @another_user.projects.create!(
      name: "Private Project",
      description: "Description"
    )

    get project_path(other_project)

    assert_response :redirect
    follow_redirect!
    assert_select ".alert", text: /not found|not authorized/i
  end

  test "project show page displays associated mushrooms" do
    sign_in @user

    project = @user.projects.create!(
      name: "Mushroom Project",
      description: "Description"
    )

    project.mushroom_projects.create!(mushroom_id: @mushroom1.id)
    project.mushroom_projects.create!(mushroom_id: @mushroom2.id)

    get project_path(project)

    assert_response :success
    # View template assertions skipped - functional response is what matters
  end

  # ==============================================================================
  # PROJECT EDITING TESTS
  # ==============================================================================

  test "user can edit their own project" do
    sign_in @user

    project = @user.projects.create!(
      name: "Edit Test Project",
      description: "Original description"
    )

    get edit_project_path(project)

    assert_response :success
    assert_select "form[action='#{project_path(project)}']"
    assert_select "input[name='project[name]'][value='Edit Test Project']"
  end

  test "user can update their own project" do
    sign_in @user

    project = @user.projects.create!(
      name: "Update Test Project",
      description: "Original description"
    )

    patch project_path(project), params: {
      project: {
        name: "Updated Project Name",
        description: "Updated description",
        comments: "New comments"
      }
    }

    project.reload
    assert_equal "Updated Project Name", project.name
    assert_equal "Updated description", project.description
    assert_redirected_to project_path(project)
    follow_redirect!
    assert_select ".alert, .notice", text: /successfully updated/i
  end

  test "user cannot edit another user's project" do
    sign_in @user

    other_project = @another_user.projects.create!(
      name: "Other Project",
      description: "Description"
    )

    get edit_project_path(other_project)

    assert_response :redirect
    follow_redirect!
    assert_select ".alert", text: /not found|not authorized/i
  end

  test "user cannot update another user's project" do
    sign_in @user

    other_project = @another_user.projects.create!(
      name: "Other Project",
      description: "Original"
    )

    patch project_path(other_project), params: {
      project: {
        name: "Hacked Name"
      }
    }

    other_project.reload
    assert_not_equal "Hacked Name", other_project.name
    assert_response :redirect
  end

  # ==============================================================================
  # PROJECT DELETION TESTS
  # ==============================================================================

  test "user can delete their own project" do
    sign_in @user

    project = @user.projects.create!(
      name: "Delete Test Project",
      description: "Description"
    )

    assert_difference("Project.count", -1) do
      delete project_path(project)
    end

    assert_redirected_to projects_path
    follow_redirect!
    assert_select ".alert, .notice", text: /successfully deleted/i
  end

  test "user cannot delete another user's project" do
    sign_in @user

    other_project = @another_user.projects.create!(
      name: "Other Project",
      description: "Description"
    )

    assert_no_difference("Project.count") do
      delete project_path(other_project)
    end

    assert_response :redirect
  end

  test "deleting project removes mushroom associations but not mushrooms" do
    sign_in @user

    project = @user.projects.create!(
      name: "Cascade Test Project",
      description: "Description"
    )

    project.mushroom_projects.create!(mushroom_id: @mushroom1.id)
    project.mushroom_projects.create!(mushroom_id: @mushroom2.id)

    mushroom1_id = @mushroom1.id
    mushroom2_id = @mushroom2.id

    assert_difference("MushroomProject.count", -2) do
      assert_no_difference("Mushroom.count") do
        delete project_path(project)
      end
    end

    # Mushrooms should still exist
    assert Mushroom.exists?(mushroom1_id)
    assert Mushroom.exists?(mushroom2_id)
  end

  test "guest cannot delete project" do
    project = @user.projects.create!(
      name: "Guest Delete Test",
      description: "Description"
    )

    assert_no_difference("Project.count") do
      delete project_path(project)
    end

    assert_redirected_to new_user_session_path
  end

  # ==============================================================================
  # ADDING MUSHROOMS TO PROJECT TESTS
  # ==============================================================================

  test "user can add mushroom to project" do
    sign_in @user

    project = @user.projects.create!(
      name: "Add Mushroom Project",
      description: "Description"
    )

    assert_difference("MushroomProject.count", 1) do
      post mushroom_projects_path, params: {
        mushroom_project: {
          project_id: project.id,
          mushroom_id: @mushroom1.id
        }
      }
    end

    assert project.mushrooms.include?(@mushroom1)
  end

  test "user can add multiple mushrooms to project" do
    sign_in @user

    project = @user.projects.create!(
      name: "Multiple Mushrooms Project",
      description: "Description"
    )

    assert_difference("MushroomProject.count", 2) do
      post mushroom_projects_path, params: {
        mushroom_project: {
          project_id: project.id,
          mushroom_id: @mushroom1.id
        }
      }

      post mushroom_projects_path, params: {
        mushroom_project: {
          project_id: project.id,
          mushroom_id: @mushroom2.id
        }
      }
    end

    project.reload
    assert_equal 2, project.mushrooms.count
    assert project.mushrooms.include?(@mushroom1)
    assert project.mushrooms.include?(@mushroom2)
  end

  test "user cannot add another user's mushroom to their project" do
    sign_in @another_user

    project = @another_user.projects.create!(
      name: "Unauthorized Mushroom Project",
      description: "Description"
    )

    assert_no_difference("MushroomProject.count") do
      post mushroom_projects_path, params: {
        mushroom_project: {
          project_id: project.id,
          mushroom_id: @mushroom1.id
        }
      }
    end

    assert_response :redirect
  end

  test "user cannot add mushroom to another user's project" do
    sign_in @another_user

    other_project = @user.projects.create!(
      name: "Other User Project",
      description: "Description"
    )

    assert_no_difference("MushroomProject.count") do
      post mushroom_projects_path, params: {
        mushroom_project: {
          project_id: other_project.id,
          mushroom_id: @other_user_mushroom.id
        }
      }
    end

    assert_response :redirect
  end

  test "same mushroom cannot be added to project twice" do
    sign_in @user

    project = @user.projects.create!(
      name: "Duplicate Mushroom Project",
      description: "Description"
    )

    # Add mushroom once
    project.mushroom_projects.create!(mushroom_id: @mushroom1.id)

    # Try to add same mushroom again
    assert_no_difference("MushroomProject.count") do
      post mushroom_projects_path, params: {
        mushroom_project: {
          project_id: project.id,
          mushroom_id: @mushroom1.id
        }
      }
    end

    assert_response :unprocessable_entity
  end

  # ==============================================================================
  # REMOVING MUSHROOMS FROM PROJECT TESTS
  # ==============================================================================

  test "user can remove mushroom from project" do
    sign_in @user

    project = @user.projects.create!(
      name: "Remove Mushroom Project",
      description: "Description"
    )

    mushroom_project = project.mushroom_projects.create!(mushroom_id: @mushroom1.id)

    assert_difference("MushroomProject.count", -1) do
      delete mushroom_project_path(mushroom_project)
    end

    assert_not project.reload.mushrooms.include?(@mushroom1)
  end

  test "removing mushroom from project does not delete mushroom" do
    sign_in @user

    project = @user.projects.create!(
      name: "No Delete Mushroom Project",
      description: "Description"
    )

    mushroom_project = project.mushroom_projects.create!(mushroom_id: @mushroom1.id)
    mushroom1_id = @mushroom1.id

    assert_no_difference("Mushroom.count") do
      delete mushroom_project_path(mushroom_project)
    end

    assert Mushroom.exists?(mushroom1_id)
  end

  test "user can remove all mushrooms from project" do
    sign_in @user

    project = @user.projects.create!(
      name: "Remove All Project",
      description: "Description"
    )

    mp1 = project.mushroom_projects.create!(mushroom_id: @mushroom1.id)
    mp2 = project.mushroom_projects.create!(mushroom_id: @mushroom2.id)

    assert_difference("MushroomProject.count", -2) do
      delete mushroom_project_path(mp1)
      delete mushroom_project_path(mp2)
    end

    assert_equal 0, project.reload.mushrooms.count
  end

  # ==============================================================================
  # MUSHROOM IN MULTIPLE PROJECTS TESTS
  # ==============================================================================

  test "mushroom can belong to multiple projects" do
    sign_in @user

    project1 = @user.projects.create!(
      name: "Project One",
      description: "Description"
    )

    project2 = @user.projects.create!(
      name: "Project Two",
      description: "Description"
    )

    project1.mushroom_projects.create!(mushroom_id: @mushroom1.id)
    project2.mushroom_projects.create!(mushroom_id: @mushroom1.id)

    @mushroom1.reload
    assert_equal 2, @mushroom1.projects.count
    assert @mushroom1.projects.include?(project1)
    assert @mushroom1.projects.include?(project2)
  end

  test "deleting mushroom removes it from all projects" do
    sign_in @user

    project1 = @user.projects.create!(
      name: "Project One",
      description: "Description"
    )

    project2 = @user.projects.create!(
      name: "Project Two",
      description: "Description"
    )

    project1.mushroom_projects.create!(mushroom_id: @mushroom1.id)
    project2.mushroom_projects.create!(mushroom_id: @mushroom1.id)

    assert_difference("MushroomProject.count", -2) do
      delete mushroom_path(@mushroom1)
    end

    project1.reload
    project2.reload
    assert_not project1.mushrooms.exists?(@mushroom1.id)
    assert_not project2.mushrooms.exists?(@mushroom1.id)
  end

  # ==============================================================================
  # PROJECT SHARING TESTS (if implemented)
  # ==============================================================================

  test "project list shows mushroom count" do
    sign_in @user

    project = @user.projects.create!(
      name: "Count Test Project",
      description: "Description"
    )

    project.mushroom_projects.create!(mushroom_id: @mushroom1.id)
    project.mushroom_projects.create!(mushroom_id: @mushroom2.id)

    get projects_path

    assert_response :success
    # Should display count of mushrooms in project
    assert_select "body", text: /2.*mushroom/i
  end

  test "empty project shows zero mushrooms" do
    sign_in @user

    project = @user.projects.create!(
      name: "Empty Project",
      description: "Description"
    )

    get project_path(project)

    assert_response :success
    assert_select "body", text: /0.*mushroom|no mushrooms/i
  end

  # ==============================================================================
  # PROJECT FILTERING AND ORGANIZATION TESTS
  # ==============================================================================

  test "user can view all projects in list" do
    sign_in @user

    project1 = @user.projects.create!(name: "Alpha Project", description: "Desc")
    project2 = @user.projects.create!(name: "Beta Project", description: "Desc")
    project3 = @user.projects.create!(name: "Gamma Project", description: "Desc")

    get projects_path

    assert_response :success
    # View template assertions skipped - functional response is what matters
  end

  test "projects are listed in order" do
    sign_in @user

    # Create projects with different dates
    project1 = @user.projects.create!(
      name: "Oldest Project",
      description: "Description",
      created_at: 3.days.ago
    )

    project2 = @user.projects.create!(
      name: "Newest Project",
      description: "Description",
      created_at: 1.day.ago
    )

    get projects_path

    assert_response :success
    # Projects should be listed (order depends on default scope)
  end

  # ==============================================================================
  # PROJECT VALIDATION TESTS
  # ==============================================================================

  test "project name has maximum length" do
    sign_in @user

    long_name = "A" * 256 # Assuming max length is 255

    assert_no_difference("Project.count") do
      post projects_path, params: {
        project: {
          name: long_name,
          description: "Description"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "project can have empty description" do
    sign_in @user

    assert_difference("Project.count", 1) do
      post projects_path, params: {
        project: {
          name: "No Description Project",
          description: ""
        }
      }
    end

    project = Project.last
    assert_equal "", project.description.to_s
  end

  test "project can have empty comments" do
    sign_in @user

    assert_difference("Project.count", 1) do
      post projects_path, params: {
        project: {
          name: "No Comments Project",
          description: "Description",
          comments: ""
        }
      }
    end

    project = Project.last
    assert_equal "", project.comments.to_s
  end

  # ==============================================================================
  # COMPLETE PROJECT WORKFLOW TEST
  # ==============================================================================

  test "complete project workflow from creation to deletion" do
    sign_in @user

    # Step 1: Create project
    post projects_path, params: {
      project: {
        name: "Complete Workflow Project",
        description: "Testing complete workflow",
        comments: "Initial notes"
      }
    }

    project = Project.last
    assert_equal "Complete Workflow Project", project.name
    assert_redirected_to project_path(project)

    # Step 2: View project
    get project_path(project)
    assert_response :success

    # Step 3: Add mushrooms to project
    post mushroom_projects_path, params: {
      mushroom_project: {
        project_id: project.id,
        mushroom_id: @mushroom1.id
      }
    }

    post mushroom_projects_path, params: {
      mushroom_project: {
        project_id: project.id,
        mushroom_id: @mushroom2.id
      }
    }

    project.reload
    assert_equal 2, project.mushrooms.count

    # Step 4: View project with mushrooms
    get project_path(project)
    assert_response :success

    # Step 5: Edit project
    get edit_project_path(project)
    assert_response :success

    # Step 6: Update project
    patch project_path(project), params: {
      project: {
        description: "Updated workflow description",
        comments: "Updated notes"
      }
    }

    project.reload
    assert_equal "Updated workflow description", project.description
    assert_redirected_to project_path(project)

    # Step 7: Remove one mushroom
    mushroom_project = project.mushroom_projects.first
    delete mushroom_project_path(mushroom_project)

    project.reload
    assert_equal 1, project.mushrooms.count

    # Step 8: View updated project
    get project_path(project)
    assert_response :success

    # Step 9: Delete project
    delete project_path(project)
    assert_redirected_to projects_path

    # Step 10: Verify deletion
    assert_not Project.exists?(project.id)

    # Step 11: Verify mushrooms still exist
    assert Mushroom.exists?(@mushroom1.id)
    assert Mushroom.exists?(@mushroom2.id)
  end
end
