require 'test_helper'

class InvitationTokenPolicyTest < ActiveSupport::TestCase
  setup do
    @admin_user = users(:three)  # Already admin with permission_id: 2
    @regular_user = users(:two)  # Already regular user with permission_id: 9

    @invitation_token = InvitationToken.new(
      email: "test@example.com",
      token: SecureRandom.hex(20)
    )
  end

  test "admin can view index" do
    assert Pundit.policy(@admin_user, InvitationToken).index?
  end

  test "admin can create new invitation" do
    assert Pundit.policy(@admin_user, @invitation_token).new?
    assert Pundit.policy(@admin_user, @invitation_token).create?
  end

  test "admin can destroy invitation" do
    assert Pundit.policy(@admin_user, @invitation_token).destroy?
  end

  test "regular user cannot view index" do
    assert_not Pundit.policy(@regular_user, InvitationToken).index?
  end

  test "regular user cannot create invitation" do
    assert_not Pundit.policy(@regular_user, @invitation_token).new?
    assert_not Pundit.policy(@regular_user, @invitation_token).create?
  end

  test "regular user cannot destroy invitation" do
    assert_not Pundit.policy(@regular_user, @invitation_token).destroy?
  end

  test "nil user cannot access anything" do
    assert_not Pundit.policy(nil, InvitationToken).index?
    assert_not Pundit.policy(nil, @invitation_token).new?
    assert_not Pundit.policy(nil, @invitation_token).create?
    assert_not Pundit.policy(nil, @invitation_token).destroy?
  end

  test "scope returns all for admin" do
    scope = Pundit.policy_scope(@admin_user, InvitationToken)
    assert_equal InvitationToken.all.to_sql, scope.to_sql
  end

  test "scope returns none for regular user" do
    scope = Pundit.policy_scope(@regular_user, InvitationToken)
    assert_equal InvitationToken.none.to_sql, scope.to_sql
  end

  test "scope returns none for nil user" do
    scope = Pundit.policy_scope(nil, InvitationToken)
    assert_equal InvitationToken.none.to_sql, scope.to_sql
  end
end
