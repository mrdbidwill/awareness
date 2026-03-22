require 'test_helper'

class AdminPolicyTest < ActiveSupport::TestCase
  setup do
    @admin_user = users(:one)
    @regular_user = users(:two)
  end

  test "should authorize admin user for access" do
    assert Pundit.policy(@admin_user, :admin).access?
  end

  test "should not authorize regular user for access" do
    assert_not Pundit.policy(@regular_user, :admin).access?
  end

  test "should not authorize nil user for access" do
    assert_not Pundit.policy(nil, :admin).access?
  end
end
