require "test_helper"

class UserTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
  end

  test "is valid with fixture data" do
    assert @user.valid?
  end

  test "admin? reflects permission tiers" do
    @user.permission_id = 1
    assert @user.admin?

    @user.permission_id = 9
    assert_not @user.admin?
  end

  test "elevated_admin? only for owner/admin permissions" do
    @user.permission_id = 2
    assert @user.elevated_admin?

    @user.permission_id = 4
    assert_not @user.elevated_admin?
  end

  test "generates otp secret on create" do
    user = User.create!(
      email: "otp-generated@example.com",
      password: "password123",
      password_confirmation: "password123",
      confirmed_at: Time.current
    )

    assert user.otp_secret.present?
  end
end
