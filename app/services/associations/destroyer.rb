# frozen_string_literal: true

module Associations
  # Generic service for destroying join table associations with proper authorization.
  #
  # Handles:
  # - Authorization checks
  # - Finding and destroying the association record
  # - Proper error handling
  #
  # Usage:
  #   result = Associations::Destroyer.call(
  #     user: current_user,
  #     parent: @mushroom,
  #     association_class: MushroomSpecies,
  #     related_id: params[:species_id]
  #   )
  class Destroyer < ApplicationService
    attr_reader :user, :parent, :association_class, :related_id, :record

    def initialize(user:, parent:, association_class:, related_id:)
      @user = user
      @parent = parent
      @association_class = association_class
      @related_id = related_id
      @record = nil
    end

    def call
      authorize!
      find_and_destroy!

      Result.success(record)
    rescue Pundit::NotAuthorizedError => e
      Result.failure(e.message)
    rescue ActiveRecord::RecordNotFound
      Result.failure("Association not found")
    rescue StandardError => e
      Result.failure("Failed to destroy association: #{e.message}")
    end

    private

    def authorize!
      Pundit.authorize(user, parent, :update?)
    end

    def find_and_destroy!
      # Determine the foreign key name based on parent class
      # e.g., for Mushroom parent: "mushroom_id"
      foreign_key = "#{parent.class.name.underscore}_id"

      # For associations, extract the related model name
      # Pattern 1: MushroomSpecies -> species_id (prefix pattern)
      # Pattern 2: GenusMushroom -> genus_id (suffix pattern)
      association_name = association_class.name.underscore
      parent_name = parent.class.name.underscore

      if association_name.start_with?(parent_name)
        # MushroomSpecies, MushroomTree, etc. -> remove prefix
        related_name = association_name.gsub(/^#{parent_name}_/, '')
      else
        # GenusMushroom, SpeciesMushroom, etc. -> remove suffix
        related_name = association_name.gsub(/_#{parent_name}$/, '')
      end

      related_key = "#{related_name}_id"

      @record = association_class.find_by!(
        foreign_key => parent.id,
        related_key => related_id
      )

      # Disable strict loading before destroy
      @record.strict_loading!(false) if @record.respond_to?(:strict_loading!)
      @record.destroy!
    end
  end
end
