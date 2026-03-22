# frozen_string_literal: true

module Mushrooms
  # Service object for deleting a mushroom with proper authorization.
  #
  # Handles:
  # - Authorization via Pundit
  # - Destroying the mushroom record and its associations
  # - Proper error handling
  #
  # Usage:
  #   result = Mushrooms::Destroyer.call(user: current_user, mushroom: @mushroom)
  #   if result.success?
  #     redirect_to mushrooms_path, notice: "Mushroom deleted"
  #   else
  #     redirect_to @mushroom, alert: result.error
  #   end
  class Destroyer < ApplicationService
    attr_reader :user, :mushroom

    def initialize(user:, mushroom:)
      @user = user
      @mushroom = mushroom
    end

    def call
      authorize!
      destroy_mushroom!

      Result.success(mushroom)
    rescue Pundit::NotAuthorizedError => e
      Result.failure(e.message)
    rescue StandardError => e
      Result.failure("Failed to delete mushroom: #{e.message}")
    end

    private

    def authorize!
      Pundit.authorize(user, mushroom, :destroy?)
    end

    def destroy_mushroom!
      # Disable strict loading to allow deletion of associations
      mushroom.strict_loading!(false) if mushroom.respond_to?(:strict_loading!)
      mushroom.destroy!
    end
  end
end
