require 'test_helper'

class ImageMushroomPolicyTest < ActiveSupport::TestCase
  setup do
    @admin_user = users(:one)
    @regular_user = users(:two)
    @owner = users(:one)
    @non_owner = users(:two)

    @mushroom = Mushroom.new(user_id: @owner.id)
    @image_mushroom = ImageMushroom.new
    @image_mushroom.mushroom = @mushroom
  end

  test "should authorize admin to view index" do
    assert Pundit.policy(@admin_user, ImageMushroom).index?
  end

  test "should not authorize regular user to view index" do
    assert_not Pundit.policy(@regular_user, ImageMushroom).index?
  end

  test "should authorize owner to show" do
    assert Pundit.policy(@owner, @image_mushroom).show?
  end

  test "should authorize admin to show" do
    assert Pundit.policy(@admin_user, @image_mushroom).show?
  end

  test "should allow public to show demo user's images only" do
    demo_mushroom = Mushroom.new(user_id: 1)
    demo_image = ImageMushroom.new(mushroom: demo_mushroom)

    non_demo_mushroom = Mushroom.new(user_id: @owner.id)
    non_demo_image = ImageMushroom.new(mushroom: non_demo_mushroom)

    assert Pundit.policy(nil, demo_image).show?
    assert_not Pundit.policy(nil, non_demo_image).show?
  end

  test "should authorize owner to new" do
    assert Pundit.policy(@owner, @image_mushroom).new?
  end

  test "should authorize admin to new" do
    assert Pundit.policy(@admin_user, @image_mushroom).new?
  end

  test "should not authorize nil user to new" do
    assert_not Pundit.policy(nil, @image_mushroom).new?
  end

  test "should authorize owner to create" do
    assert Pundit.policy(@owner, @image_mushroom).create?
  end

  test "should authorize admin to create" do
    assert Pundit.policy(@admin_user, @image_mushroom).create?
  end

  test "should authorize owner to edit" do
    assert Pundit.policy(@owner, @image_mushroom).edit?
  end

  test "should authorize admin to edit" do
    assert Pundit.policy(@admin_user, @image_mushroom).edit?
  end

  test "should authorize owner to update" do
    assert Pundit.policy(@owner, @image_mushroom).update?
  end

  test "should authorize admin to update" do
    assert Pundit.policy(@admin_user, @image_mushroom).update?
  end

  test "should authorize owner to destroy" do
    assert Pundit.policy(@owner, @image_mushroom).destroy?
  end

  test "should authorize admin to destroy" do
    assert Pundit.policy(@admin_user, @image_mushroom).destroy?
  end
end
