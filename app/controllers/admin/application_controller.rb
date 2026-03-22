# app/controllers/admin/application_controller.rb
class Admin::ApplicationController < ApplicationController
  include Pundit::Authorization

  before_action :authenticate_user! # Ensure the user is logged in for admin namespace access
  before_action :authorize_admin_access! # Ensure only certain users have access to admin

  after_action :verify_authorized # Enforce policy checks for all actions
  after_action :verify_policy_scoped, only: :index # Enforce scoping for index actions

  rescue_from Pundit::NotAuthorizedError do
    redirect_to root_path, alert: "You are not authorized to access this area."
  end

  private

  def authorize_admin_access!
    # Use Pundit policy check for access to the Admin namespace
    authorize :admin, :access?
  end
end
