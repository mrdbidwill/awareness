# frozen_string_literal: true

module Mushrooms
  # Service object for exporting mushrooms to PDF format.
  #
  # Handles:
  # - Authorization checks
  # - Loading mushrooms with proper eager loading
  # - Delegating to PDF generation service
  # - Generating appropriate filenames
  #
  # Usage:
  #   result = Mushrooms::PdfExporter.call(
  #     user: current_user,
  #     mushroom_ids: [1, 2, 3]  # or single ID or nil for all
  #   )
  #   if result.success?
  #     send_data result.data[:pdf], filename: result.data[:filename], type: 'application/pdf'
  #   end
  class PdfExporter < ApplicationService
    attr_reader :user, :mushroom_ids

    def initialize(user:, mushroom_ids: nil)
      @user = user
      @mushroom_ids = Array(mushroom_ids).compact
    end

    def call
      mushrooms = load_mushrooms
      authorize_mushrooms!(mushrooms)

      pdf = MushroomPdfService.new(mushrooms).generate
      filename = generate_filename(mushrooms)

      Result.success({ pdf: pdf.render, filename: filename })
    rescue Pundit::NotAuthorizedError => e
      # Re-raise authorization errors so controller can handle with proper response
      raise
    rescue ActiveRecord::RecordNotFound
      Result.failure("Mushroom not found")
    rescue StandardError => e
      Result.failure("Failed to generate PDF: #{e.message}")
    end

    private

    def load_mushrooms
      scope = Mushroom.includes(
        :country, :state, :fungus_type, :genera, :species, :trees, :plants,
        image_mushrooms: { image_file_attachment: :blob },
        mr_character_mushrooms: { mr_character: [:part, :display_option] }
      )

      if mushroom_ids.empty?
        # All user's mushrooms
        scope.where(user_id: user.id).order(:name)
      elsif mushroom_ids.one?
        # Single mushroom
        [scope.find(mushroom_ids.first)]
      else
        # Multiple specific mushrooms
        scope.where(id: mushroom_ids, user_id: user.id).order(:name)
      end
    end

    def authorize_mushrooms!(mushrooms)
      mushrooms.each do |mushroom|
        Pundit.authorize(user, mushroom, :export_pdf?)
      end
    end

    def generate_filename(mushrooms)
      if mushrooms.one?
        "#{mushrooms.first.name.parameterize}-#{Date.today}.pdf"
      elsif mushroom_ids.any?
        "mushrooms-export-#{Date.today}.pdf"
      else
        "all-mushrooms-#{Date.today}.pdf"
      end
    end
  end
end
