require "test_helper"

class Admin::InvitationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @user.permission_id = 2  # Admin permission
    sign_in @user
  end

  test "should get index" do
    get admin_invitations_path
    assert_response :success
  end

  test "should get new" do
    get new_admin_invitation_path
    assert_response :success
  end

  test "should create invitation with valid email" do
    assert_difference("InvitationToken.count") do
      post admin_invitations_path, params: {
        invitation_token: {
          email: "newuser@example.com"
        }
      }
    end

    assert_redirected_to admin_invitations_path
    assert_equal "Invitation sent to newuser@example.com", flash[:notice]
  end

  test "should not create invitation with invalid email" do
    assert_no_difference("InvitationToken.count") do
      post admin_invitations_path, params: {
        invitation_token: {
          email: ""
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should destroy invitation" do
    invitation = InvitationToken.create!(
      email: "test@example.com",
      token: SecureRandom.hex(20),
      created_by: @user
    )

    assert_difference("InvitationToken.count", -1) do
      delete admin_invitation_path(invitation)
    end

    assert_redirected_to admin_invitations_path
    assert_equal "Invitation deleted", flash[:notice]
  end

  test "non-admin should not access invitations" do
    sign_out @user
    
    regular_user = users(:one)
    regular_user.permission_id = 9  # Member permission
    sign_in regular_user

    get admin_invitations_path
    assert_redirected_to root_path
  end
end
