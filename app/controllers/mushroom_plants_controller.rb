# frozen_string_literal: true

class MushroomPlantsController < ApplicationController
  before_action :authenticate_user!

  # Skip Pundit verification - authorization handled by service objects
  skip_after_action :verify_authorized, raise: false

  # POST /mushroom_plants.json
  def create
    # Validate params before attempting to find mushroom
    if mushroom_plant_params[:mushroom_id].blank? || mushroom_plant_params[:plant_id].blank?
      render json: { success: false, errors: ["Mushroom and plant are required"] }, status: :unprocessable_entity
      return
    end

    mushroom = Mushroom.find(mushroom_plant_params[:mushroom_id])

    result = Associations::Creator.call(
      user: current_user,
      parent: mushroom,
      association_class: MushroomPlant,
      attributes: mushroom_plant_params
    )

    if result.success?
      render json: { success: true, id: result.data.id }, status: :created
    else
      # Extract error messages from validation errors or use result.error string
      if result.data.is_a?(MushroomPlant) && result.data.errors.any?
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
    render json: { success: false, errors: ["Invalid mushroom or plant"] }, status: :unprocessable_entity
  rescue ActiveRecord::RecordNotUnique
    render json: { success: false, errors: ["This plant is already associated with this mushroom"] }, status: :unprocessable_entity
  end

  # DELETE /mushroom_plants/destroy_by_relation.json
  def destroy_by_relation
    mushroom = Mushroom.find(params[:mushroom_id])

    result = Associations::Destroyer.call(
      user: current_user,
      parent: mushroom,
      association_class: MushroomPlant,
      related_id: params[:plant_id]
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

  def mushroom_plant_params
    params.require(:mushroom_plant).permit(:mushroom_id, :plant_id)
  end
end
