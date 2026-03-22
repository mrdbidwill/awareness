# frozen_string_literal: true

require "test_helper"

class AdminProjectsRequestTest < ActionDispatch::IntegrationTest
  setup do
    @admin_user = users(:one)   # Owner/Admin
    @regular_user = users(:two) # Regular user
  end

  test "guest is redirected to sign in" do
    get admin_projects_path
    assert_redirected_to new_user_session_path
  end

  test "regular user is denied access to admin projects" do
    sign_in @regular_user

    get admin_projects_path
    assert_response :redirect
    assert_redirected_to root_path
    follow_redirect!
    assert_select ".alert", text: /not authorized/i
  end

  test "admin can view universal and user-specific projects" do
    sign_in @admin_user

    universal_project = Project.create!(name: "Universal Admin Project", user: nil)
    user_project = Project.create!(name: "User Project Alpha", user: @regular_user)

    get admin_projects_path
    assert_response :success
    assert_includes response.body, universal_project.name
    assert_includes response.body, user_project.name
  end

  test "admin index displays counter cache count" do
    sign_in @admin_user

    project = Project.create!(name: "Counter Cache Project", user: nil)
    mushroom = mushrooms(:one)
    MushroomProject.create!(project: project, mushroom: mushroom)

    assert_equal 1, project.reload.mushroom_projects_count

    get admin_projects_path
    assert_response :success
    assert_includes response.body, project.name
    assert_includes response.body, "(1 specimens)"
  end
end
