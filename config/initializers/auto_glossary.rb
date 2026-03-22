# frozen_string_literal: true

# Skip Pundit authorization and Devise authentication for AutoGlossary engine
# See RAILS_ENGINE_SETUP.md for why this is necessary
#
# Problem: ApplicationController has `after_action :verify_authorized` which applies
# to ALL controllers including mounted engine controllers. The AutoGlossary engine
# controllers don't call `authorize`, causing 401 Unauthorized errors.
#
# Additionally, Devise's authenticate_user! may be present globally.
#
# Solution: Skip Pundit verification and Devise authentication for AutoGlossary controllers
Rails.application.config.to_prepare do
  AutoGlossary::GlossaryController.class_eval do
    skip_after_action :verify_authorized, raise: false
    skip_after_action :verify_policy_scoped, raise: false
    skip_before_action :authenticate_user!, raise: false if respond_to?(:authenticate_user!)

    # Ensure public access
    def authenticate_user!
      # Override to allow public access to glossary
    end
  end
end
