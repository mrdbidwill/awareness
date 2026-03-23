require "test_helper"

class SubjectPolicyTest < ActiveSupport::TestCase
  setup do
    @admin_user = users(:one)
    @regular_user = users(:two)
    @subject = subjects(:mycology)
  end

  test "admin can manage subjects" do
    policy = Pundit.policy(@admin_user, @subject)

    assert policy.index?
    assert policy.show?
    assert policy.create?
    assert policy.update?
    assert policy.destroy?
  end

  test "regular user cannot manage subjects" do
    policy = Pundit.policy(@regular_user, @subject)

    assert_not policy.index?
    assert_not policy.show?
    assert_not policy.create?
    assert_not policy.update?
    assert_not policy.destroy?
  end
end
