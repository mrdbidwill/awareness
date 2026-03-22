require 'test_helper'

class MushroomProjectPolicyTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @other_user = users(:two)

    @project = Project.new(user_id: @user.id, name: "Test Project")
    @mushroom = Mushroom.new(user_id: @user.id)
    @mushroom_project = MushroomProject.new(project: @project, mushroom: @mushroom)

    @other_project = Project.new(user_id: @other_user.id, name: "Other Project")
    @other_mushroom = Mushroom.new(user_id: @other_user.id)
    @other_mushroom_project = MushroomProject.new(project: @other_project, mushroom: @other_mushroom)
  end

  test "should authorize any user to view index" do
    assert Pundit.policy(@user, MushroomProject).index?
    assert Pundit.policy(@other_user, MushroomProject).index?
  end

  test "should authorize any signed-in user to create new" do
    assert Pundit.policy(@user, MushroomProject.new).new?
    assert Pundit.policy(@other_user, MushroomProject.new).new?
  end

  test "should not authorize nil user to create new" do
    assert_not Pundit.policy(nil, MushroomProject.new).new?
  end

  test "should authorize owner to create when mushroom and project are owned" do
    assert Pundit.policy(@user, @mushroom_project).create?
  end

  test "should not authorize non-owner to create" do
    assert_not Pundit.policy(@other_user, @mushroom_project).create?
  end

  test "should not authorize nil user to create" do
    assert_not Pundit.policy(nil, @mushroom_project).create?
  end

  test "should authorize owner via project to show" do
    assert Pundit.policy(@user, @mushroom_project).show?
  end

  test "should authorize owner via mushroom to show" do
    assert Pundit.policy(@user, @mushroom_project).show?
  end

  test "should not authorize non-owner to show" do
    assert_not Pundit.policy(@other_user, @mushroom_project).show?
  end

  test "should authorize owner to edit" do
    assert Pundit.policy(@user, @mushroom_project).edit?
  end

  test "should not authorize non-owner to edit" do
    assert_not Pundit.policy(@other_user, @mushroom_project).edit?
  end

  test "should authorize owner to update" do
    assert Pundit.policy(@user, @mushroom_project).update?
  end

  test "should not authorize non-owner to update" do
    assert_not Pundit.policy(@other_user, @mushroom_project).update?
  end

  test "should authorize owner to destroy" do
    assert Pundit.policy(@user, @mushroom_project).destroy?
  end

  test "should not authorize non-owner to destroy" do
    assert_not Pundit.policy(@other_user, @mushroom_project).destroy?
  end
end
