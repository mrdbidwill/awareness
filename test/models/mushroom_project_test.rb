# test/models/mushroom_project_test.rb
require "test_helper"

class MushroomProjectTest < ActiveSupport::TestCase
  def setup
    @mushroom = mushrooms(:one)
    @project = projects(:one)
    @mushroom_project = mushroom_projects(:one)
  end

  # === Validations ===

  test "should be valid with valid attributes" do
    assert @mushroom_project.valid?
  end

  test "should require mushroom" do
    mushroom_project = MushroomProject.new(project: @project)
    assert_not mushroom_project.valid?
    assert_includes mushroom_project.errors[:mushroom], "must exist"
  end

  test "should require project" do
    mushroom_project = MushroomProject.new(mushroom: @mushroom)
    assert_not mushroom_project.valid?
    assert_includes mushroom_project.errors[:project], "must exist"
  end

  test "should enforce unique project per mushroom" do
    # Clean up any existing associations from fixtures
    MushroomProject.where(mushroom: @mushroom, project: @project).destroy_all
    MushroomProject.create!(mushroom: @mushroom, project: @project)
    duplicate = MushroomProject.new(mushroom: @mushroom, project: @project)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:project_id], "is already attached to this mushroom"
  end

  # === Associations ===

  test "should belong to mushroom" do
    assert_respond_to @mushroom_project, :mushroom
    assert_instance_of Mushroom, @mushroom_project.mushroom
  end

  test "should belong to project" do
    assert_respond_to @mushroom_project, :project
    assert_instance_of Project, @mushroom_project.project
  end

  # === CRUD Operations ===

  test "should create mushroom_project" do
    project2 = Project.create!(name: "Another Project", user: @mushroom.user)
    assert_difference "MushroomProject.count", 1 do
      MushroomProject.create!(mushroom: @mushroom, project: project2)
    end
  end

  test "should delete mushroom_project" do
    assert_difference "MushroomProject.count", -1 do
      @mushroom_project.destroy
    end
  end

  test "should have timestamps" do
    assert_not_nil @mushroom_project.created_at
    assert_not_nil @mushroom_project.updated_at
  end

  # === Business Logic ===

  test "should allow same project for different mushrooms" do
    mushroom2 = Mushroom.create!(
      name: "Another Mushroom",
      user: @mushroom.user,
      country: countries(:one),
      fungus_type: fungus_types(:one),
      collection_date: Date.today
    )
    mushroom_project2 = MushroomProject.new(mushroom: mushroom2, project: @project)
    assert mushroom_project2.valid?
  end

  test "should allow same mushroom with different projects" do
    project2 = Project.create!(name: "Project 2", user: @mushroom.user)
    mushroom_project2 = MushroomProject.new(mushroom: @mushroom, project: project2)
    assert mushroom_project2.valid?
  end
end
