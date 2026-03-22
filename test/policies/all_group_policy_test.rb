require 'test_helper'

class AllGroupPolicyTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @other_user = users(:two)
    @all_group = AllGroup.new(user_id: @user.id, name: "Test Group")
    @other_all_group = AllGroup.new(user_id: @other_user.id, name: "Other Group")
  end

  test "should authorize any user to view index" do
    assert Pundit.policy(@user, AllGroup).index?
    assert Pundit.policy(@other_user, AllGroup).index?
  end

  test "should authorize any user to create new" do
    assert Pundit.policy(@user, AllGroup.new).new?
    assert Pundit.policy(@other_user, AllGroup.new).new?
  end

  test "should authorize owner to create" do
    assert Pundit.policy(@user, @all_group).create?
  end

  test "should not authorize non-owner to create" do
    assert_not Pundit.policy(@other_user, @all_group).create?
  end

  test "should authorize owner to show" do
    assert Pundit.policy(@user, @all_group).show?
  end

  test "should not authorize non-owner to show" do
    assert_not Pundit.policy(@other_user, @all_group).show?
  end

  test "should authorize owner to edit" do
    assert Pundit.policy(@user, @all_group).edit?
  end

  test "should not authorize non-owner to edit" do
    assert_not Pundit.policy(@other_user, @all_group).edit?
  end

  test "should authorize owner to update" do
    assert Pundit.policy(@user, @all_group).update?
  end

  test "should not authorize non-owner to update" do
    assert_not Pundit.policy(@other_user, @all_group).update?
  end

  test "should authorize owner to destroy" do
    assert Pundit.policy(@user, @all_group).destroy?
  end

  test "should not authorize non-owner to destroy" do
    assert_not Pundit.policy(@other_user, @all_group).destroy?
  end
end
