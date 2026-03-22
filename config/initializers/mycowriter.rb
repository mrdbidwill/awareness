# frozen_string_literal: true

# Mycowriter configuration
Mycowriter.configure do |config|
  # Minimum number of characters required before autocomplete triggers
  # Default: 4 (prevents excessive matches like "a", "ag", "aga")
  config.min_characters = 4

  # Require uppercase first letter for genus names
  # Default: true (genus names always start with capital letter: Agaricus, not agaricus)
  config.require_uppercase = true

  # Maximum number of results to return
  # Default: 20
  config.results_limit = 20
end

# Configure Mycowriter engine controllers
# Require authentication via Devise and skip Pundit authorization
# This must run AFTER devise_authentication.rb initializer
Rails.application.config.after_initialize do
  Mycowriter::AutocompleteController.class_eval do
    before_action :authenticate_user!
    skip_after_action :verify_authorized, raise: false
    skip_after_action :verify_policy_scoped, raise: false
  end
end
