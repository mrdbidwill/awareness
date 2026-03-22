require 'test_helper'

class SourceDataPolicyTest < ActiveSupport::TestCase
  setup do
    @admin_user = users(:one)
    @regular_user = users(:two)
    @source_data = SourceData.new(title: "Test Source Data", source_data_type_id: 1)
  end

  test "should authorize admin to view index" do
    assert Pundit.policy(@admin_user, SourceData).index?
  end

  test "should not authorize regular user to view index" do
    assert_not Pundit.policy(@regular_user, SourceData).index?
  end

  test "should not authorize nil user to view index" do
    assert_not Pundit.policy(nil, SourceData).index?
  end

  test "should authorize admin to show" do
    assert Pundit.policy(@admin_user, @source_data).show?
  end

  test "should not authorize regular user to show" do
    assert_not Pundit.policy(@regular_user, @source_data).show?
  end

  test "should authorize admin to new" do
    assert Pundit.policy(@admin_user, SourceData.new).new?
  end

  test "should not authorize regular user to new" do
    assert_not Pundit.policy(@regular_user, SourceData.new).new?
  end

  test "should authorize admin to create" do
    assert Pundit.policy(@admin_user, SourceData.new).create?
  end

  test "should not authorize regular user to create" do
    assert_not Pundit.policy(@regular_user, SourceData.new).create?
  end

  test "should authorize admin to edit" do
    assert Pundit.policy(@admin_user, @source_data).edit?
  end

  test "should not authorize regular user to edit" do
    assert_not Pundit.policy(@regular_user, @source_data).edit?
  end

  test "should authorize admin to update" do
    assert Pundit.policy(@admin_user, @source_data).update?
  end

  test "should not authorize regular user to update" do
    assert_not Pundit.policy(@regular_user, @source_data).update?
  end

  test "should authorize admin to destroy" do
    assert Pundit.policy(@admin_user, @source_data).destroy?
  end

  test "should not authorize regular user to destroy" do
    assert_not Pundit.policy(@regular_user, @source_data).destroy?
  end
end
