# frozen_string_literal: true

class GuestSessionsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:create]
  skip_after_action :verify_authorized, only: [:create], raise: false

  def create
    support_email = ENV.fetch("SUPPORT_EMAIL", "support@awareness.example.com")
    token = InvitationToken.find_by(token: params[:token])

    if token.nil?
      redirect_to root_path, alert: 'Invalid invitation link'
      return
    end

    if token.used?
      redirect_to root_path, alert: "This invitation has already been used. Please contact #{support_email} for assistance."
      return
    end

    if token.expired?
      redirect_to root_path, alert: "This invitation has expired. Please contact #{support_email} for a new invitation."
      return
    end

    # Create or find user
    user = User.find_by(email: token.email)

    if user.nil?
      # Create new temporary admin user
      user = User.new(
        email: token.email,
        display_name: token.email.split('@').first.titleize,
        password: SecureRandom.urlsafe_base64(32),
        permission_id: 2, # Admin
        temporary_admin: true,
        admin_expires_at: token.admin_expires_at,
        confirmed_at: Time.current # Skip email confirmation
      )

      # Skip password validation and confirmation emails
      user.skip_confirmation_notification!
      user.save!(validate: false)
    else
      # User already exists - upgrade to temporary admin
      user.update!(
        permission_id: 2,
        temporary_admin: true,
        admin_expires_at: token.admin_expires_at
      )
    end

    # Mark token as used
    token.mark_as_used!(user)

    # Sign in the user (bypass 2FA for temporary admins)
    sign_in(user)

    redirect_to authenticated_root_path, notice: "Welcome! You have full admin access until #{user.admin_expires_at.strftime('%B %d at %l:%M %p')}. To continue after that, create a regular account and email #{support_email} to upgrade to permanent admin."
  end
end
