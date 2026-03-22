require "test_helper"

class ProjectsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @project = Project.create!(name: "Test Project", user: @user)
    sign_in @user
  end

  test "should get index" do
    get projects_url
    assert_response :success
  end

  test "should get new" do
    get new_project_url
    assert_response :success
  end

  test "should create project" do
    assert_difference("Project.count") do
      post projects_url, params: {
        project: {
          name: "New Project",
          description: "Test description",
          comments: "Test comments"
        }
      }
    end

    assert_redirected_to project_url(Project.last)
    assert_equal "Project was successfully created.", flash[:notice]
  end

  test "should show project" do
    get project_url(@project)
    assert_response :success
  end

  test "should show project as JSON" do
    get project_url(@project), as: :json
    assert_response :success
  end

  test "should get edit" do
    get edit_project_url(@project)
    assert_response :success
  end

  test "should update project" do
    patch project_url(@project), params: {
      project: {
        name: "Updated Project"
      }
    }

    assert_redirected_to @project
    assert_equal "Project was successfully updated.", flash[:notice]
  end

  test "should destroy project" do
    assert_difference("Project.count", -1) do
      delete project_url(@project)
    end

    assert_redirected_to projects_url
    assert_equal "Project was successfully deleted.", flash[:notice]
  end

  test "should only show own projects" do
    other_user = users(:two)
    other_project = Project.create!(name: "Other Project", user: other_user)

    get project_url(other_project)
    assert_redirected_to projects_path
    assert_match /Project not found/, flash[:alert]
  end

  test "should only edit own projects" do
    other_user = users(:two)
    other_project = Project.create!(name: "Other Project", user: other_user)

    get edit_project_url(other_project)
    assert_redirected_to projects_path
    assert_match /Project not found/, flash[:alert]
  end

  test "should handle invalid creation" do
    assert_no_difference("Project.count") do
      post projects_url, params: {
        project: {
          name: ""  # Invalid
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should handle invalid update" do
    patch project_url(@project), params: {
      project: {
        name: ""  # Invalid
      }
    }

    assert_response :unprocessable_entity
  end

  test "should require authentication" do
    sign_out @user

    get projects_url
    assert_redirected_to new_user_session_path
  end
end
