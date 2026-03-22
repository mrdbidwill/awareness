require 'test_helper'

class CountryPolicyTest < ActiveSupport::TestCase
  setup do
    @admin_user = users(:one)
    @regular_user = users(:two)
    @country = Country.new(name: "Test Country")
  end

  test "should authorize any user to view index" do
    assert Pundit.policy(@regular_user, Country).index?
    assert Pundit.policy(@admin_user, Country).index?
  end

  test "should authorize any user to show" do
    assert Pundit.policy(@regular_user, @country).show?
    assert Pundit.policy(@admin_user, @country).show?
  end

  test "should authorize admin to new" do
    assert Pundit.policy(@admin_user, Country.new).new?
  end

  test "should not authorize regular user to new" do
    assert_not Pundit.policy(@regular_user, Country.new).new?
  end

  test "should not authorize nil user to new" do
    assert_not Pundit.policy(nil, Country.new).new?
  end

  test "should authorize admin to create" do
    assert Pundit.policy(@admin_user, Country.new).create?
  end

  test "should not authorize regular user to create" do
    assert_not Pundit.policy(@regular_user, Country.new).create?
  end

  test "should authorize admin to edit" do
    assert Pundit.policy(@admin_user, @country).edit?
  end

  test "should not authorize regular user to edit" do
    assert_not Pundit.policy(@regular_user, @country).edit?
  end

  test "should authorize admin to update" do
    assert Pundit.policy(@admin_user, @country).update?
  end

  test "should not authorize regular user to update" do
    assert_not Pundit.policy(@regular_user, @country).update?
  end

  test "should authorize admin to destroy" do
    assert Pundit.policy(@admin_user, @country).destroy?
  end

  test "should not authorize regular user to destroy" do
    assert_not Pundit.policy(@regular_user, @country).destroy?
  end
end
