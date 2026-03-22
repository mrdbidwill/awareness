# Manages the ApplicationController
# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :set_paper_trail_whodunnit
  before_action :set_view_debug_identifier, if: -> { Rails.env.development? || Rails.env.test? }  # see file name on each page
  before_action :_debug_views_reset, if: -> { Rails.env.development? || Rails.env.test? }
  before_action :check_temporary_admin_expiration, if: :user_signed_in?
  helper_method :rendered_views_debug

  include Pundit::Authorization # Updated inclusion for Pundit
  # Make Pundit's policy and policy_scope methods available to views
  helper_method :policy, :policy_scope

  # Error handling
  # Define the generic handler first so more specific handlers take priority.
  rescue_from StandardError, with: :handle_internal_error
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActiveRecord::StrictLoadingViolationError, with: :handle_strict_loading_violation
  rescue_from ActiveStorage::FileNotFoundError, with: :handle_missing_file

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  helper :all # This includes all helpers in view contexts
  helper MrCharactersHelper

  # Configure permitted parameters for Devise
  before_action :configure_permitted_parameters, if: :devise_controller?

  # Ensure actions are authorized and index actions are policy-scoped in all environments.
  # Skips Devise controllers to avoid noise in auth flows.
  # This prevents environment-specific bugs where callbacks exist in dev/test but not production.
  after_action :verify_authorized, unless: -> { devise_controller? || action_name == 'index' }
  after_action :verify_policy_scoped, unless: -> { devise_controller? || action_name != 'index' || !action_has_index? }

  # Check if current user is an elevated admin (Owner/Admin only)
  # This method is made available to views via helper_method (see below)
  #
  # Purpose: Enable inline edit links for admins in user-facing workflows
  # Admin users see small edit icons (⚙️, ✏️) next to characters and lookup items
  # that link directly to admin edit pages with automatic return navigation.
  #
  # Returns:
  #   true - if user is signed in AND has admin permissions
  #   false - if user not signed in or not an admin
  #
  # Usage in views:
  #   <% if admin_user? %>
  #     <%= link_to "Edit", edit_admin_path(..., return_to: request.fullpath) %>
  #   <% end %>
  def admin_user?
    # Helper method to check admin status
    user_signed_in? && current_user.elevated_admin?
  end
  helper_method :admin_user?

  private

  # Helper to determine if the current controller implements an :index action
  def action_has_index?
    self.class.action_methods.include?('index')
  end


  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:display_name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:display_name])
  end

  def after_sign_in_path_for(resource)
    authenticated_root_path
  end

  def after_sign_out_path_for(resource_or_scope)
    root_path
  end

  def after_inactive_sign_up_path_for(resource)
    root_path
  end

  def check_temporary_admin_expiration
    return unless current_user.admin_expired?

    if current_user.check_and_downgrade_expired_admin!
      sign_out current_user
      support_email = ENV.fetch("SUPPORT_EMAIL", "support@awareness.mrdbid.com")
      redirect_to root_path, alert: "Your temporary admin access has expired. To continue, please create a regular account and email #{support_email} to request permanent admin access."
    end
  end

  def require_admin!
    unless current_user&.permission_id == 1
      flash[:alert] = "Admin access required."
      redirect_to root_path
    end
  end

  private
  def user_not_authorized
    respond_to do |format|
      format.html do
        flash[:alert] = "You are not authorized to perform this action."
        # For non-GET requests, prefer 303 See Other to avoid form resubmission issues with Turbo.
        fallback = root_path
        if request.get?
          redirect_back fallback_location: fallback
        else
          redirect_to (request.referer || fallback), status: :see_other, allow_other_host: false
        end
      end

      format.pdf do
        render plain: "You are not authorized to perform this action.", status: :forbidden, content_type: "text/plain"
      end

      format.json do
        render json: { error: "forbidden", message: "You are not authorized to perform this action." }, status: :forbidden
      end
    end
  end

  def record_not_found(exception)
    Rails.logger.error "Record not found: #{exception.message}"
    Rails.logger.error exception.backtrace.join("\n")

    respond_to do |format|
      format.html do
        flash[:alert] = "The record you were looking for could not be found."
        redirect_to root_path, status: :not_found
      end
      format.json do
        render json: { error: "not_found", message: "Record not found" }, status: :not_found
      end
    end
  end

  def handle_strict_loading_violation(exception)
    Rails.logger.error "Strict loading violation: #{exception.message}"
    Rails.logger.error exception.backtrace.join("\n")

    @error_message = "A database query error occurred."
    @error_details = is_admin? ? exception.message : nil
    render "errors/internal_error", status: :internal_server_error
  end

  def handle_missing_file(exception)
    Rails.logger.error "Missing file: #{exception.message}"
    Rails.logger.error exception.backtrace.join("\n")

    respond_to do |format|
      format.html do
        flash[:alert] = "The requested file could not be found. It may have been deleted."
        redirect_back fallback_location: root_path, status: :not_found
      end
      format.json do
        render json: { error: "file_not_found", message: "File not found" }, status: :not_found
      end
    end
  end

  def handle_internal_error(exception)
    # Don't catch exceptions in development/test - let them bubble up for debugging
    raise exception if Rails.env.development? || Rails.env.test?

    Rails.logger.error "Internal error: #{exception.class} - #{exception.message}"
    Rails.logger.error exception.backtrace.join("\n")

    @error_message = "An unexpected error occurred. The issue has been logged and will be investigated."
    @error_details = is_admin? ? "#{exception.class}: #{exception.message}" : nil
    render "errors/internal_error", status: :internal_server_error
  end

  def is_admin?
    current_user&.elevated_admin?
  end

  def set_view_debug_identifier
    # Find the main template for this request and expose a relative path
    template = lookup_context.find_template(action_name.to_s, lookup_context.prefixes, false) rescue nil
    @view_debug_identifier = template&.identifier&.sub("#{Rails.root}/", "")
  end

  def _debug_views_reset
    Thread.current[:rendered_views] = []
  end

  # Helper used by the layout to read the collected list at render time
  def rendered_views_debug
    Array(Thread.current[:rendered_views]).uniq
  end
end
