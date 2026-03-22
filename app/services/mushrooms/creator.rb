# frozen_string_literal: true

module Mushrooms
  # Service object for creating a new mushroom with proper authorization and validation.
  #
  # Handles:
  # - Authorization via Pundit
  # - Creating the mushroom record
  # - Setting default values
  # - Proper error handling
  #
  # Usage:
  #   result = Mushrooms::Creator.call(user: current_user, params: mushroom_params)
  #   if result.success?
  #     redirect_to result.data
  #   else
  #     @mushroom = result.data
  #     render :new, status: :unprocessable_entity
  #   end
  class Creator < ApplicationService
    attr_reader :user, :params, :mushroom

    def initialize(user:, params:)
      @user = user
      @params = params
      @mushroom = nil
    end

    def call
      authorize!
      create_mushroom!

      if mushroom.persisted?
        Result.success(mushroom)
      else
        Result.failure(mushroom.errors.full_messages.join(", "), data: mushroom)
      end
    rescue Pundit::NotAuthorizedError => e
      Result.failure(e.message)
    end

    private

    def authorize!
      # Check if user can create mushrooms (Pundit policy check)
      Pundit.authorize(user, Mushroom, :create?)
    end

    def create_mushroom!
      @mushroom = user.mushrooms.build(params)
      @mushroom.save
    end
  end
end
