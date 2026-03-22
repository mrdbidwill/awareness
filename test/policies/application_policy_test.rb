require 'test_helper'

class ApplicationPolicyTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @record = Object.new
  end

  test "should deny index by default" do
    assert_not ApplicationPolicy.new(@user, @record).index?
  end

  test "should deny show by default" do
    assert_not ApplicationPolicy.new(@user, @record).show?
  end

  test "should deny create by default" do
    assert_not ApplicationPolicy.new(@user, @record).create?
  end

  test "should deny new by default (delegates to create)" do
    assert_not ApplicationPolicy.new(@user, @record).new?
  end

  test "should deny update by default" do
    assert_not ApplicationPolicy.new(@user, @record).update?
  end

  test "should deny edit by default (delegates to update)" do
    assert_not ApplicationPolicy.new(@user, @record).edit?
  end

  test "should deny destroy by default" do
    assert_not ApplicationPolicy.new(@user, @record).destroy?
  end

  test "scope should raise NoMethodError for resolve" do
    assert_raises(NoMethodError) do
      ApplicationPolicy::Scope.new(@user, Object).resolve
    end
  end
end
