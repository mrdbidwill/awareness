# frozen_string_literal: true

module Mushrooms
  # Service object for updating an existing mushroom with proper authorization.
  #
  # Handles:
  # - Authorization via Pundit
  # - Updating the mushroom record
  # - Proper error handling
  # - Maintaining audit trail
  #
  # Usage:
  #   result = Mushrooms::Updater.call(user: current_user, mushroom: @mushroom, params: mushroom_params)
  #   if result.success?
  #     redirect_to result.data
  #   else
  #     @mushroom = result.data
  #     render :edit, status: :unprocessable_entity
  #   end
  class Updater < ApplicationService
    attr_reader :user, :mushroom, :params

    def initialize(user:, mushroom:, params:)
      @user = user
      @mushroom = mushroom
      @params = params
    end

    def call
      authorize!
      update_mushroom!

      if mushroom.errors.empty?
        Result.success(mushroom)
      else
        Result.failure(mushroom.errors.full_messages.join(", "), data: mushroom)
      end
    rescue Pundit::NotAuthorizedError => e
      Result.failure(e.message)
    end

    private

    def authorize!
      Pundit.authorize(user, mushroom, :update?)
    end

    def update_mushroom!
      mushroom.update(params)
    end
  end
end
