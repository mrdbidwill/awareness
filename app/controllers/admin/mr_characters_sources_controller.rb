# app/controllers/admin/mr_characters_sources_controller.rb
# frozen_string_literal: true

require "csv"

module Admin
  class MrCharactersSourcesController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_admin!
    # Avoid Pundit's verify_policy_scoped check on a non-routed index here
    skip_after_action :verify_policy_scoped, only: [:index], raise: false
    # Skip Pundit verification - authorization handled via ensure_admin! check
    skip_after_action :verify_authorized, raise: false

    # Define index to satisfy Rails 7.1 callback validation (not routed)
    def index
      redirect_to action: :show
    end

    def show
      csv_path = Rails.root.join("public", "docs", "mr_characters_source.csv")
      unless File.exist?(csv_path)
        redirect_back(fallback_location: root_path, alert: "Source CSV not found at #{csv_path}.") and return
      end

      rows = CSV.read(csv_path, headers: true)
      @headers = rows.headers
      @rows = rows
    end

    private

    def ensure_admin!
      unless current_user&.admin?
        redirect_to root_path, alert: "You are not authorized to view this page."
      end
    end
  end
end