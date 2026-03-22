# app/controllers/users/sessions_controller.rb
class Users::SessionsController < Devise::SessionsController
  # Customize the actions as needed. For example:
  def create
    self.resource = warden.authenticate!(auth_options)
    if resource.otp_required_for_login
      # Check if this device is trusted
      if trusted_device_valid?(resource)
        # Skip 2FA and sign in directly
        sign_in(resource_name, resource)
        redirect_to authenticated_root_path, notice: 'Signed in successfully.'
      else
        # Redirect user to OTP flow if enabled
        session[:otp_user_id] = resource.id
        redirect_to user_two_factor_authentication_path
      end
    else
      # Default behavior - sign in and redirect
      sign_in(resource_name, resource)
      redirect_to authenticated_root_path, notice: 'Signed in successfully.'
    end
  end

  def destroy
    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
    set_flash_message! :notice, :signed_out if signed_out
    redirect_to root_path
  end

  private

  def trusted_device_valid?(user)
    return false unless cookies.encrypted[:trusted_device_token].present?

    device_token = cookies.encrypted[:trusted_device_token]
    fingerprint = device_fingerprint

    trusted_device = user.trusted_devices.active.find_by(
      device_token: device_token,
      device_fingerprint: fingerprint
    )

    if trusted_device&.active?
      true
    else
      # Clear invalid cookie
      cookies.delete(:trusted_device_token)
      false
    end
  end

  def device_fingerprint
    Digest::SHA256.hexdigest("#{request.user_agent}-#{request.remote_ip}")
  end
end
