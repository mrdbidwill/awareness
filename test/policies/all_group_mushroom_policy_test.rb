require 'test_helper'

class AllGroupMushroomPolicyTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @other_user = users(:two)

    # Create mushrooms owned by users
    @mushroom = mushrooms(:one)
    @mushroom.user = @user
    @mushroom.save!

    @other_mushroom = mushrooms(:two)
    @other_mushroom.user = @other_user
    @other_mushroom.save!

    # Create all_groups
    @all_group = all_groups(:one)
    @all_group.user = @user
    @all_group.save!

    @other_all_group = all_groups(:two)
    @other_all_group.user = @other_user
    @other_all_group.save!

    @all_group_mushroom = AllGroupMushroom.new(all_group: @all_group, mushroom: @mushroom)
    @other_all_group_mushroom = AllGroupMushroom.new(all_group: @other_all_group, mushroom: @other_mushroom)
  end

  test "should authorize index for any user" do
    assert Pundit.policy(@user, AllGroupMushroom).index?
    assert Pundit.policy(@other_user, AllGroupMushroom).index?
  end

  test "should authorize owner to create" do
    assert Pundit.policy(@user, @all_group_mushroom).create?
  end

  test "should not authorize non-owner to create" do
    assert_not Pundit.policy(@other_user, @all_group_mushroom).create?
  end

  test "should authorize owner to show" do
    assert Pundit.policy(@user, @all_group_mushroom).show?
  end

  test "should not authorize non-owner to show" do
    assert_not Pundit.policy(@other_user, @all_group_mushroom).show?
  end

  test "should authorize owner to update" do
    assert Pundit.policy(@user, @all_group_mushroom).update?
  end

  test "should not authorize non-owner to update" do
    assert_not Pundit.policy(@other_user, @all_group_mushroom).update?
  end

  test "should authorize owner to destroy" do
    assert Pundit.policy(@user, @all_group_mushroom).destroy?
  end

  test "should not authorize non-owner to destroy" do
    assert_not Pundit.policy(@other_user, @all_group_mushroom).destroy?
  end

  test "should authorize owner to edit" do
    assert Pundit.policy(@user, @all_group_mushroom).edit?
  end

  test "should authorize owner to create new" do
    assert Pundit.policy(@user, @all_group_mushroom).new?
  end
end
