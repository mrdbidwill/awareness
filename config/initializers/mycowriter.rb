# frozen_string_literal: true

# Mycowriter configuration
Mycowriter.configure do |config|
  config.min_characters = 4
  config.require_uppercase = true
  config.results_limit = 20
end

# Skip Pundit/Devise callbacks for engine endpoints
Rails.application.config.to_prepare do
  Mycowriter::AutocompleteController.class_eval do
    skip_after_action :verify_authorized, raise: false
    skip_after_action :verify_policy_scoped, raise: false
    skip_before_action :authenticate_user!, raise: false if respond_to?(:authenticate_user!)
  end
end
