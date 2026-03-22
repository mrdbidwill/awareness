require 'test_helper'

class ClusterMushroomPolicyTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @cluster_mushroom = ClusterMushroom.new
  end

  test "should authorize any user to view index" do
    assert Pundit.policy(@user, ClusterMushroom).index?
  end

  test "should authorize any user to show" do
    assert Pundit.policy(@user, @cluster_mushroom).show?
  end

  test "should authorize any user to create" do
    assert Pundit.policy(@user, ClusterMushroom.new).create?
  end

  test "should authorize any user to new" do
    assert Pundit.policy(@user, ClusterMushroom.new).new?
  end

  test "should authorize any user to update" do
    assert Pundit.policy(@user, @cluster_mushroom).update?
  end

  test "should authorize any user to edit" do
    assert Pundit.policy(@user, @cluster_mushroom).edit?
  end

  test "should authorize any user to destroy" do
    assert Pundit.policy(@user, @cluster_mushroom).destroy?
  end
end
