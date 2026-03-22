# frozen_string_literal: true

# Add authentication callback to ApplicationController after Devise is initialized
Rails.application.config.to_prepare do
  ApplicationController.class_eval do
    before_action :authenticate_user!, unless: -> { devise_controller? || self.class.name =~ /^(Mycowriter|AutoGlossary)::/ }
  end
end
