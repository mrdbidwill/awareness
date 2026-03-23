# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]
  before_action :check_honeypot, only: [:create]

  # Override create to ensure proper redirect
  def create
    build_resource(sign_up_params)

    resource.save
    yield resource if block_given?
    if resource.persisted?
      if resource.active_for_authentication?
        sign_up(resource_name, resource)
        redirect_to authenticated_root_path, notice: 'Welcome! You have signed up successfully.'
      else
        expire_data_after_sign_in!
        redirect_to root_path, notice: "A message with a confirmation link has been sent to your email address. Please follow the link to activate your account."
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  # Override update to add debugging
  def update
    Rails.logger.info "=" * 80
    Rails.logger.info "Account update params: #{params[:user]&.keys}"
    Rails.logger.info "=" * 80
    super
  end

  # Allow updating without password if only updating non-sensitive fields
  def update_resource(resource, params)
    # If user is only updating non-sensitive profile fields, skip password requirement
    if params[:password].blank? && params[:email] == resource.email
      resource.update_without_password(params.except(:current_password))
    else
      resource.update_with_password(params)
    end
  end

  # Override destroy to handle strict_loading
  def destroy
    resource.strict_loading!(false)
    super
  end

  protected

  def after_update_path_for(resource)
    authenticated_root_path
  end

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:display_name])
  end

  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [:display_name])
  end

  private

  def check_honeypot
    # If the honeypot field is filled, it's likely a bot
    if params[:user] && params[:user][:website_url].present?
      Rails.logger.warn "Bot registration attempt detected: #{params[:user][:email]}"
      redirect_to new_user_registration_path, alert: "Registration failed. Please try again."
    end
  end
end
