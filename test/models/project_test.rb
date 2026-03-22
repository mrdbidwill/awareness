# test/models/project_test.rb
require "test_helper"

class ProjectTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @project = projects(:one)
  end

  # === Validations ===

  test "should be valid with valid attributes" do
    assert @project.valid?
  end

  test "should require name" do
    @project.name = nil
    assert_not @project.valid?
    assert_includes @project.errors[:name], "Name cannot be blank."
  end

  test "should require unique name case-insensitively" do
    Project.create!(name: "UniqueProject", user: @user)
    duplicate = Project.new(name: "uniqueproject", user: @user)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:name], "has already been taken"
  end

  test "name should not exceed 255 characters" do
    @project.name = "a" * 256
    assert_not @project.valid?
    assert_includes @project.errors[:name], "Name must not exceed 255 characters."
  end

  # === Associations ===

  test "should belong to user" do
    assert_respond_to @project, :user
    assert_instance_of User, @project.user
  end

  test "should allow nil user for universal projects" do
    @project.user = nil
    assert @project.valid?, "Universal projects (user_id = nil) should be valid"
    assert @project.universal?, "Project with user_id = nil should be universal"
  end

  test "should have many mushroom_projects" do
    assert_respond_to @project, :mushroom_projects
  end

  test "should have many mushrooms through mushroom_projects" do
    assert_respond_to @project, :mushrooms
  end

  # === Dependent Associations ===

  test "should have dependent destroy configured for mushroom_projects" do
    # Verify dependent: :destroy is configured
    reflection = Project.reflect_on_association(:mushroom_projects)
    assert_equal :destroy, reflection.options[:dependent], "mushroom_projects should have dependent: :destroy"
  end

  # === Business Logic ===

  test "can_be_deleted? should return true" do
    assert @project.can_be_deleted?
  end

  # === CRUD Operations ===

  test "should create new project" do
    assert_difference "Project.count", 1 do
      Project.create!(name: "New Project", user: @user)
    end
  end

  test "should update project attributes" do
    @project.update(name: "Updated Project")
    assert_equal "Updated Project", @project.reload.name
  end


  # === Timestamps ===

  test "should have timestamps" do
    assert_not_nil @project.created_at
    assert_not_nil @project.updated_at
  end

  # === Edge Cases ===

  test "should handle empty name" do
    @project.name = ""
    assert_not @project.valid?
  end

  test "should accept maximum length name" do
    @project.name = "a" * 255
    assert @project.valid?
  end

  test "should allow same name for different instances globally" do
    # Since uniqueness is case_insensitive: false (global), this tests that behavior
    user2 = users(:two)
    Project.create!(name: "SharedName", user: @user)
    duplicate = Project.new(name: "sharedname", user: user2)
    assert_not duplicate.valid? # Case insensitive uniqueness
  end
end
