require "test_helper"

class ReferencePolicyTest < ActiveSupport::TestCase
  setup do
    @admin_user = users(:one)
    @regular_user = users(:two)
    @reference = references(:one)
  end

  test "admin can manage references" do
    policy = Pundit.policy(@admin_user, @reference)

    assert policy.index?
    assert policy.show?
    assert policy.create?
    assert policy.update?
    assert policy.destroy?
  end

  test "regular user cannot manage references" do
    policy = Pundit.policy(@regular_user, @reference)

    assert_not policy.index?
    assert_not policy.show?
    assert_not policy.create?
    assert_not policy.update?
    assert_not policy.destroy?
  end
end
