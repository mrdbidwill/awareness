require "test_helper"

class MushroomProjectsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @mushroom = mushrooms(:one)
    @mushroom.user = @user
    @mushroom.save!
    @project = Project.create!(name: "Test Project", user: @user)
    @mushroom_project = MushroomProject.create!(
      mushroom: @mushroom,
      project: @project
    )
    sign_in @user
  end

  test "should get index" do
    get mushroom_projects_url
    assert_response :success
  end

  test "should get new" do
    get new_mushroom_project_url(mushroom_id: @mushroom.id)
    assert_response :success
  end

  test "should show mushroom_project" do
    get mushroom_project_url(@mushroom_project)
    assert_response :success
  end

  test "should create mushroom_project" do
    new_mushroom = Mushroom.create!(
      user: @user,
      name: "Test Mushroom",
      collection_date: Date.today,
      country_id: countries(:one).id,
      fungus_type_id: fungus_types(:one).id
    )

    assert_difference("MushroomProject.count") do
      post mushroom_projects_url, params: {
        mushroom_project: {
          mushroom_id: new_mushroom.id,
          project_id: @project.id
        }
      }
    end

    assert_redirected_to mushrooms_path
    assert_equal "Group was successfully added.", flash[:notice]
  end

  test "should get edit" do
    get edit_mushroom_project_url(@mushroom_project)
    assert_response :success
  end

  test "should update mushroom_project" do
    new_project = Project.create!(name: "Another Project", user: @user)

    patch mushroom_project_url(@mushroom_project), params: {
      mushroom_project: {
        project_id: new_project.id
      }
    }

    assert_redirected_to mushroom_project_path(@mushroom_project)
    assert_equal "All group mushroom was successfully updated.", flash[:notice]
  end

  test "should destroy mushroom_project" do
    assert_difference("MushroomProject.count", -1) do
      delete mushroom_project_url(@mushroom_project)
    end

    assert_redirected_to mushrooms_path
    assert_equal "The group was successfully removed.", flash[:notice]
  end

  test "should handle invalid creation" do
    assert_no_difference("MushroomProject.count") do
      post mushroom_projects_url, params: {
        mushroom_project: {
          mushroom_id: nil,
          project_id: nil
        }
      }
    end

    # Authorization checks happen before validation, so we get a redirect
    assert_redirected_to mushrooms_path
    assert_equal "You can only add mushrooms to your own or universal projects.", flash[:alert]
  end

  test "should require authentication" do
    sign_out @user

    get mushroom_projects_url
    assert_redirected_to new_user_session_path
  end
end
