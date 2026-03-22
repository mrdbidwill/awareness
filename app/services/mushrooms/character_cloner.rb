# frozen_string_literal: true

module Mushrooms
  # Service object for cloning characters from one mushroom to another.
  #
  # Handles:
  # - Authorization checks (user must own target, source must be accessible)
  # - Cloning character assignments and their color associations
  # - Transaction safety
  # - Proper error handling
  #
  # Usage:
  #   result = Mushrooms::CharacterCloner.call(
  #     user: current_user,
  #     source_mushroom: source,
  #     target_mushroom: target
  #   )
  #   if result.success?
  #     redirect_to target, notice: "Cloned #{result.data[:count]} characters"
  #   else
  #     redirect_to target, alert: result.error
  #   end
  class CharacterCloner < ApplicationService
    attr_reader :user, :source_mushroom, :target_mushroom

    def initialize(user:, source_mushroom:, target_mushroom:)
      @user = user
      @source_mushroom = source_mushroom
      @target_mushroom = target_mushroom
    end

    def call
      authorize!
      count = clone_characters!

      Result.success({ mushroom: target_mushroom, count: count })
    rescue Pundit::NotAuthorizedError => e
      Result.failure(e.message)
    rescue StandardError => e
      Result.failure("Failed to clone characters: #{e.message}")
    end

    private

    def authorize!
      # User must be able to update the target mushroom
      Pundit.authorize(user, target_mushroom, :update?)

      # Source must be either user's own mushroom or a public template
      unless source_mushroom.user_id == user.id || source_mushroom.is_template?
        raise Pundit::NotAuthorizedError, "You do not have permission to clone from that mushroom."
      end
    end

    def clone_characters!
      count = 0

      ActiveRecord::Base.transaction do
        source_mushroom.mr_character_mushrooms.includes(:colors).each do |source_char_mushroom|
          # Skip if target already has this character
          next if target_mushroom.mr_character_mushrooms.exists?(
            mr_character_id: source_char_mushroom.mr_character_id
          )

          # Create new character assignment
          new_char_mushroom = target_mushroom.mr_character_mushrooms.create!(
            mr_character_id: source_char_mushroom.mr_character_id,
            character_value: source_char_mushroom.character_value
          )

          # Clone color associations if any
          source_char_mushroom.colors.each do |color|
            new_char_mushroom.colors << color unless new_char_mushroom.colors.include?(color)
          end

          count += 1
        end
      end

      count
    end
  end
end
