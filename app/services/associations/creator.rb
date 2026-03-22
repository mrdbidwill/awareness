# frozen_string_literal: true

module Associations
  # Generic service for creating join table associations with proper authorization.
  #
  # Handles:
  # - Authorization checks
  # - Creating the association record
  # - Proper error handling
  #
  # Usage:
  #   result = Associations::Creator.call(
  #     user: current_user,
  #     parent: @mushroom,
  #     association_class: MushroomSpecies,
  #     attributes: { species_id: params[:species_id], is_primary: true }
  #   )
  class Creator < ApplicationService
    attr_reader :user, :parent, :association_class, :attributes, :record

    def initialize(user:, parent:, association_class:, attributes:)
      @user = user
      @parent = parent
      @association_class = association_class
      @attributes = attributes
      @record = nil
    end

    def call
      authorize!
      create_association!

      if record.persisted?
        Result.success(record)
      else
        # Return the record with validation errors for proper error message extraction
        Result.failure(record.errors.full_messages.join(", "), data: record)
      end
    rescue Pundit::NotAuthorizedError => e
      Result.failure(e.message)
    rescue ActiveRecord::RecordNotUnique => e
      # Let the controller handle this specific error
      raise
    rescue StandardError => e
      Result.failure("Failed to create association: #{e.message}")
    end

    private

    def authorize!
      # Check if user can update the parent record
      Pundit.authorize(user, parent, :update?)
    end

    def create_association!
      @record = association_class.new(attributes)
      @record.save
    end
  end
end
