require 'test_helper'

class SourceDataTypePolicyTest < ActiveSupport::TestCase
  setup do
    @admin_user = users(:one)
    @regular_user = users(:two)
    @source_data_type = SourceDataType.new(name: "Test Source Data Type")
  end

  test "should authorize admin to view index" do
    assert Pundit.policy(@admin_user, SourceDataType).index?
  end

  test "should not authorize regular user to view index" do
    assert_not Pundit.policy(@regular_user, SourceDataType).index?
  end

  test "should not authorize nil user to view index" do
    assert_not Pundit.policy(nil, SourceDataType).index?
  end

  test "should authorize admin to show" do
    assert Pundit.policy(@admin_user, @source_data_type).show?
  end

  test "should not authorize regular user to show" do
    assert_not Pundit.policy(@regular_user, @source_data_type).show?
  end

  test "should authorize admin to new" do
    assert Pundit.policy(@admin_user, SourceDataType.new).new?
  end

  test "should not authorize regular user to new" do
    assert_not Pundit.policy(@regular_user, SourceDataType.new).new?
  end

  test "should authorize admin to create" do
    assert Pundit.policy(@admin_user, SourceDataType.new).create?
  end

  test "should not authorize regular user to create" do
    assert_not Pundit.policy(@regular_user, SourceDataType.new).create?
  end

  test "should authorize admin to edit" do
    assert Pundit.policy(@admin_user, @source_data_type).edit?
  end

  test "should not authorize regular user to edit" do
    assert_not Pundit.policy(@regular_user, @source_data_type).edit?
  end

  test "should authorize admin to update" do
    assert Pundit.policy(@admin_user, @source_data_type).update?
  end

  test "should not authorize regular user to update" do
    assert_not Pundit.policy(@regular_user, @source_data_type).update?
  end

  test "should authorize admin to destroy" do
    assert Pundit.policy(@admin_user, @source_data_type).destroy?
  end

  test "should not authorize regular user to destroy" do
    assert_not Pundit.policy(@regular_user, @source_data_type).destroy?
  end
end
