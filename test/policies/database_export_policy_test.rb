require 'test_helper'

class DatabaseExportPolicyTest < ActiveSupport::TestCase
  setup do
    @admin_user = users(:one)
    @regular_user = users(:two)
  end

  test "should authorize admin user for export" do
    assert Pundit.policy(@admin_user, :database_export).export?
  end

  test "should not authorize regular user for export" do
    assert_not Pundit.policy(@regular_user, :database_export).export?
  end

  test "should not authorize nil user for export" do
    assert_not Pundit.policy(nil, :database_export).export?
  end
end
