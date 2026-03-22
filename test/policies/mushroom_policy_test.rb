require 'test_helper'

class MushroomPolicyTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @other_user = users(:two)
    @mushroom = mushrooms(:one) # Owned by @user
  end

  test "should authorize owner to edit and destroy" do
    assert Pundit.policy(@user, @mushroom).edit?
    assert Pundit.policy(@user, @mushroom).destroy?
  end

  test "should not authorize another user to edit and destroy" do
    assert_not Pundit.policy(@other_user, @mushroom).edit?
    assert_not Pundit.policy(@other_user, @mushroom).destroy?
  end

  def test_scope
    scope = Pundit.policy_scope!(@user, Mushroom)
    assert_includes scope, @mushroom
  end

  def test_show
    # Owner can view their own mushroom
    assert Pundit.policy(@user, @mushroom).show?
    # Any signed-in user can view any mushroom (public viewing)
    assert Pundit.policy(@other_user, @mushroom).show?
  end

  def test_create
    assert Pundit.policy(@user, Mushroom.new).create?
  end

  def test_update
    assert Pundit.policy(@user, @mushroom).update?
    assert_not Pundit.policy(@other_user, @mushroom).update?
  end

  def test_destroy
    assert Pundit.policy(@user, @mushroom).destroy?
    assert_not Pundit.policy(@other_user, @mushroom).destroy?
  end
end
