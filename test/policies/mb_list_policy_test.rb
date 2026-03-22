require 'test_helper'

class MbListPolicyTest < ActiveSupport::TestCase
  setup do
    @admin_user = users(:three)  # Already admin with permission_id: 2
    @regular_user = users(:two)  # Already regular user with permission_id: 9

    @mb_list = MbList.new(taxon_name: "Test Taxon")
  end

  test "admin can perform all actions" do
    policy = Pundit.policy(@admin_user, @mb_list)
    
    assert policy.index?
    assert policy.show?
    assert policy.new?
    assert policy.create?
    assert policy.edit?
    assert policy.update?
    assert policy.destroy?
  end

  test "regular user cannot perform any actions" do
    policy = Pundit.policy(@regular_user, @mb_list)
    
    assert_not policy.index?
    assert_not policy.show?
    assert_not policy.new?
    assert_not policy.create?
    assert_not policy.edit?
    assert_not policy.update?
    assert_not policy.destroy?
  end

  test "nil user cannot perform any actions" do
    policy = Pundit.policy(nil, @mb_list)
    
    assert_not policy.index?
    assert_not policy.show?
    assert_not policy.new?
    assert_not policy.create?
    assert_not policy.edit?
    assert_not policy.update?
    assert_not policy.destroy?
  end

  test "scope returns all for admin" do
    scope = Pundit.policy_scope(@admin_user, MbList)
    assert_equal MbList.all.to_sql, scope.to_sql
  end

  test "scope returns none for regular user" do
    scope = Pundit.policy_scope(@regular_user, MbList)
    assert_equal MbList.none.to_sql, scope.to_sql
  end

  test "scope returns none for nil user" do
    scope = Pundit.policy_scope(nil, MbList)
    assert_equal MbList.none.to_sql, scope.to_sql
  end
end
