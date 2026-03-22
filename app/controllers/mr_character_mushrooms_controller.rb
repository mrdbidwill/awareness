class MrCharacterMushroomsController < ApplicationController
  # Add Pundit if you authorize mushrooms; ensure policy permits linking characters
  before_action :authenticate_user!
  before_action :set_mushroom, except: [:bulk_update]
  before_action :set_mushroom_for_bulk, only: [:bulk_update]
  before_action :authorize_mushroom!, only: [:create, :bulk_update]
  skip_after_action :verify_authorized, raise: false

  def create
    # Upsert behavior: one value per mushroom+character, update if exists
    @rc = MrCharacterMushroom.find_or_initialize_by(
      mushroom_id: @mushroom.id,
      mr_character_id: params[:mr_character_id]
    )

    # Handle color characters differently (via join table)
    if color_character?(params[:mr_character_id])
      # Set color_ids (can be single value or array)
      color_ids = params[:color_ids].presence || [params[:character_value]].compact

      # If clearing all colors, delete the record instead of saving empty
      if color_ids.empty? && @rc.persisted?
        @rc.destroy
        redirect_path = params[:redirect_to].presence || edit_mushroom_path(@mushroom)
        redirect_to redirect_path, notice: "Character cleared.", status: :see_other
        return
      end

      @rc.color_ids = color_ids
    elsif booleanish_display_option?(params[:mr_character_id])
      @rc.character_value = normalize_boolean_string(params[:character_value])
    else
      @rc.character_value = params[:character_value]
    end

    # Determine where to redirect after save (back to grid or edit page)
    redirect_path = params[:redirect_to].presence || edit_mushroom_path(@mushroom)
    if params[:save_next].present? && params[:next_url].present?
      redirect_path = params[:next_url]
    end

    if @rc.save
      redirect_to redirect_path, notice: "Character saved.", status: :see_other
    else
      redirect_to redirect_path, alert: @rc.errors.full_messages.to_sentence, status: :see_other
    end
  end

  def bulk_update
    # Accept array of character updates and process them in a transaction
    updates = params[:updates]&.values || []

    if updates.empty?
      redirect_path = params[:redirect_to].presence || edit_mushroom_path(@mushroom)
      redirect_to redirect_path, alert: "No updates provided.", status: :see_other
      return
    end

    success_count = 0
    error_messages = []

    ActiveRecord::Base.transaction do
      updates.each do |update|
        character_id = update[:mr_character_id]
        value = update[:character_value]

        # Skip if missing required data
        next unless character_id.present?

        # Find or initialize the character-mushroom record
        rc = MrCharacterMushroom.find_or_initialize_by(
          mushroom_id: @mushroom.id,
          mr_character_id: character_id
        )

        # Handle color characters differently (via join table)
        if color_character?(character_id)
          color_ids = [value].compact
          if color_ids.empty? && rc.persisted?
            rc.destroy
            success_count += 1
            next
          end
          rc.color_ids = color_ids
        elsif booleanish_display_option?(character_id)
          rc.character_value = normalize_boolean_string(value)
        else
          rc.character_value = value
        end

        if rc.save
          success_count += 1
        else
          error_messages << "Character #{character_id}: #{rc.errors.full_messages.join(', ')}"
        end
      end
    end

    redirect_path = params[:redirect_to].presence || edit_mushroom_path(@mushroom)

    if error_messages.any?
      redirect_to redirect_path, alert: "Saved #{success_count} characters. Errors: #{error_messages.join('; ')}", status: :see_other
    else
      redirect_to redirect_path, notice: "Successfully saved #{success_count} character#{success_count == 1 ? '' : 's'}.", status: :see_other
    end
  end

  private

  def set_mushroom
    @mushroom = Mushroom.find(params[:mushroom_id])
  end

  def set_mushroom_for_bulk
    @mushroom = Mushroom.find(params[:mushroom_id])
  end

  def authorize_mushroom!
    authorize @mushroom, :update?
  end

  # Display option helpers

  def color_character?(mr_character_id)
    mc = MrCharacter.includes(:display_option).find_by(id: mr_character_id)
    mc&.display_option_id == 6
  end

  def booleanish_display_option?(mr_character_id)
    mc = MrCharacter.includes(:display_option).find_by(id: mr_character_id)
    return false unless mc&.display_option&.name
    %w[boolean_yes_no boolean_true_false boolean_present_absent checkbox].include?(mc.display_option.name)
  end

  def normalize_boolean_string(value)
    v = value.to_s.strip.downcase
    return "true"  if %w[true yes present y on 1 checked].include?(v)
    return "false" if %w[false no absent n off 0 unchecked].include?(v)
    # Fallback: empty becomes false, anything else stays as-is to avoid data loss
    return "false" if v.blank?
    value.to_s
  end
end
