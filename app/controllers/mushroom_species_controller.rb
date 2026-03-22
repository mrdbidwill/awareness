# frozen_string_literal: true

class MushroomSpeciesController < ApplicationController
  before_action :authenticate_user!

  # Skip Pundit verification - authorization handled by service objects
  skip_after_action :verify_authorized, raise: false

  # POST /mushroom_species.json
  def create
    # Validate params before attempting to find mushroom
    if mushroom_species_params[:mushroom_id].blank? || mushroom_species_params[:species_id].blank?
      render json: { success: false, errors: ["Mushroom and species are required"] }, status: :unprocessable_entity
      return
    end

    mushroom = Mushroom.find(mushroom_species_params[:mushroom_id])

    result = Associations::Creator.call(
      user: current_user,
      parent: mushroom,
      association_class: MushroomSpecies,
      attributes: mushroom_species_params
    )

    if result.success?
      render json: { success: true, id: result.data.id }, status: :created
    else
      # Extract error messages from validation errors or use result.error string
      if result.data.is_a?(MushroomSpecies) && result.data.errors.any?
        errors = result.data.errors.full_messages
      elsif result.error.is_a?(String)
        errors = [result.error]
      else
        errors = ["Failed to create association"]
      end
      render json: { success: false, errors: errors }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    # Invalid mushroom_id - treat as validation error not 404
    render json: { success: false, errors: ["Invalid mushroom or species"] }, status: :unprocessable_entity
  rescue ActiveRecord::RecordNotUnique
    render json: { success: false, errors: ["This species is already associated with this mushroom"] }, status: :unprocessable_entity
  end

  # DELETE /mushroom_species/destroy_by_relation.json
  def destroy_by_relation
    mushroom = Mushroom.find(params[:mushroom_id])

    result = Associations::Destroyer.call(
      user: current_user,
      parent: mushroom,
      association_class: MushroomSpecies,
      related_id: params[:species_id]
    )

    if result.success?
      render json: { success: true }
    else
      render json: { success: false, message: result.error }, status: :not_found
    end
  rescue ActiveRecord::RecordNotFound
    render json: { success: false, message: "Mushroom not found" }, status: :not_found
  end

  private

  def mushroom_species_params
    params.require(:mushroom_species).permit(:mushroom_id, :species_id)
  end
end
