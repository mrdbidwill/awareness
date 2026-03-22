require 'test_helper'

class ClusterPolicyTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @other_user = users(:two)
    @cluster = Cluster.new(user_id: @user.id, name: "Test Cluster")
    @other_cluster = Cluster.new(user_id: @other_user.id, name: "Other Cluster")
  end

  test "should authorize any user to view index" do
    assert Pundit.policy(@user, Cluster).index?
    assert Pundit.policy(@other_user, Cluster).index?
  end

  test "should authorize any user to create new" do
    assert Pundit.policy(@user, Cluster.new).new?
    assert Pundit.policy(@other_user, Cluster.new).new?
  end

  test "should authorize owner to create" do
    assert Pundit.policy(@user, @cluster).create?
  end

  test "should not authorize non-owner to create" do
    assert_not Pundit.policy(@other_user, @cluster).create?
  end

  test "should authorize owner to show" do
    assert Pundit.policy(@user, @cluster).show?
  end

  test "should not authorize non-owner to show" do
    assert_not Pundit.policy(@other_user, @cluster).show?
  end

  test "should authorize owner to edit" do
    assert Pundit.policy(@user, @cluster).edit?
  end

  test "should not authorize non-owner to edit" do
    assert_not Pundit.policy(@other_user, @cluster).edit?
  end

  test "should authorize owner to update" do
    assert Pundit.policy(@user, @cluster).update?
  end

  test "should not authorize non-owner to update" do
    assert_not Pundit.policy(@other_user, @cluster).update?
  end

  test "should authorize owner to destroy" do
    assert Pundit.policy(@user, @cluster).destroy?
  end

  test "should not authorize non-owner to destroy" do
    assert_not Pundit.policy(@other_user, @cluster).destroy?
  end
end
