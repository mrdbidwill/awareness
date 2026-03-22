# frozen_string_literal: true

class Users::TwoFactorSettingsController < ApplicationController
  before_action :authenticate_user!

  # Skip Pundit verification - authorization handled via authentication (users manage own 2FA)
  skip_after_action :verify_authorized, raise: false

  def enable
    if current_user.otp_required_for_login?
      redirect_to edit_user_registration_path, alert: '2FA is already enabled.'
      return
    end

    begin
      # Regenerate OTP secret for security
      current_user.otp_secret = User.generate_otp_secret

      if current_user.save
        # Store that we're in setup mode
        session[:enabling_otp] = true
        redirect_to edit_user_registration_path, notice: 'Scan the QR code and enter a verification code to enable 2FA.'
      else
        redirect_to edit_user_registration_path, alert: "Failed to enable 2FA: #{current_user.errors.full_messages.join(', ')}"
      end
    rescue StandardError => e
      Rails.logger.error "2FA Enable Error: #{e.message}\n#{e.backtrace.join("\n")}"
      redirect_to edit_user_registration_path, alert: "Failed to enable 2FA. Please contact support if this persists."
    end
  end

  def verify
    otp_attempt = params[:otp_attempt]

    if otp_attempt.blank?
      redirect_to edit_user_registration_path, alert: 'Please enter the verification code.'
      return
    end

    # Verify the OTP code
    if current_user.validate_and_consume_otp!(otp_attempt)
      # Enable 2FA
      current_user.otp_required_for_login = true

      # Generate backup codes and capture plain text versions before they're hashed
      plain_codes = current_user.generate_otp_backup_codes!

      if current_user.save
        # Clear setup mode
        session.delete(:enabling_otp)

        # Show backup codes (plain text versions)
        flash[:notice] = '2FA has been enabled successfully! Save these backup codes:'
        flash[:backup_codes] = plain_codes
        redirect_to edit_user_registration_path
      else
        redirect_to edit_user_registration_path, alert: 'Failed to save 2FA settings.'
      end
    else
      redirect_to edit_user_registration_path, alert: 'Invalid verification code. Please try again.'
    end
  end

  def disable
    unless current_user.valid_password?(params[:current_password])
      redirect_to edit_user_registration_path, alert: 'Invalid password. Cannot disable 2FA.'
      return
    end

    current_user.otp_required_for_login = false
    current_user.otp_backup_codes = []

    if current_user.save
      session.delete(:enabling_otp)
      redirect_to edit_user_registration_path, notice: '2FA has been disabled.'
    else
      redirect_to edit_user_registration_path, alert: 'Failed to disable 2FA.'
    end
  end
end
