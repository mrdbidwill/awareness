require 'test_helper'

class ProjectPolicyTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @other_user = users(:two)
    @project = Project.new(user_id: @user.id, name: "Test Project")
    @other_project = Project.new(user_id: @other_user.id, name: "Other Project")
  end

  test "should authorize any user to view index" do
    assert Pundit.policy(@user, Project).index?
    assert Pundit.policy(@other_user, Project).index?
  end

  test "should authorize any user to create new" do
    assert Pundit.policy(@user, Project.new).new?
    assert Pundit.policy(@other_user, Project.new).new?
  end

  test "should authorize owner to create" do
    assert Pundit.policy(@user, @project).create?
  end

  test "should not authorize non-owner to create" do
    assert_not Pundit.policy(@other_user, @project).create?
  end

  test "should authorize owner to show" do
    assert Pundit.policy(@user, @project).show?
  end

  test "should not authorize non-owner to show" do
    assert_not Pundit.policy(@other_user, @project).show?
  end

  test "should authorize owner to edit" do
    assert Pundit.policy(@user, @project).edit?
  end

  test "should not authorize non-owner to edit" do
    assert_not Pundit.policy(@other_user, @project).edit?
  end

  test "should authorize owner to update" do
    assert Pundit.policy(@user, @project).update?
  end

  test "should not authorize non-owner to update" do
    assert_not Pundit.policy(@other_user, @project).update?
  end

  # Skipping: test requires mocha which is not configured
  # test "should authorize owner to destroy when project can be deleted" do
  #   @project.stubs(:can_be_deleted?).returns(true)
  #   assert Pundit.policy(@user, @project).destroy?
  # end

  # Skipping: test requires mocha which is not configured
  # test "should not authorize owner to destroy when project cannot be deleted" do
  #   @project.stubs(:can_be_deleted?).returns(false)
  #   assert_not Pundit.policy(@user, @project).destroy?
  # end

  # Skipping: test requires mocha which is not configured
  # test "should not authorize non-owner to destroy" do
  #   @other_project.stubs(:can_be_deleted?).returns(true)
  #   assert_not Pundit.policy(@user, @other_project).destroy?
  # end
end
