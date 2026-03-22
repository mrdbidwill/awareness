# frozen_string_literal: true

class GenusMushroomsController < ApplicationController
  before_action :authenticate_user!

  # Skip Pundit verification - authorization handled by service objects
  skip_after_action :verify_authorized, raise: false

  # POST /genus_mushrooms.json
  def create
    # Validate params before attempting to find mushroom
    if genus_mushroom_params[:mushroom_id].blank? || genus_mushroom_params[:genus_id].blank?
      render json: { success: false, errors: ["Mushroom and genus are required"] }, status: :unprocessable_entity
      return
    end

    mushroom = Mushroom.find(genus_mushroom_params[:mushroom_id])

    result = Associations::Creator.call(
      user: current_user,
      parent: mushroom,
      association_class: GenusMushroom,
      attributes: genus_mushroom_params
    )

    if result.success?
      render json: { success: true, id: result.data.id }, status: :created
    else
      # Extract error messages from validation errors or use result.error string
      if result.data.is_a?(GenusMushroom) && result.data.errors.any?
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
    render json: { success: false, errors: ["Invalid mushroom or genus"] }, status: :unprocessable_entity
  rescue ActiveRecord::RecordNotUnique
    render json: { success: false, errors: ["This genus is already associated with this mushroom"] }, status: :unprocessable_entity
  end

  # DELETE /genus_mushrooms/destroy_by_relation.json
  def destroy_by_relation
    mushroom = Mushroom.find(params[:mushroom_id])

    result = Associations::Destroyer.call(
      user: current_user,
      parent: mushroom,
      association_class: GenusMushroom,
      related_id: params[:genus_id]
    )

    if result.success?
      render json: { success: true }
    else
      render json: { success: false, message: result.error }, status: :not_found
    end
  rescue ActiveRecord::RecordNotFound
    render json: { success: false, message: "Mushroom not found" }, status: :not_found
  rescue StandardError => e
    render json: { success: false, message: e.message }, status: :internal_server_error
  end

  private

  def genus_mushroom_params
    params.require(:genus_mushroom).permit(:mushroom_id, :genus_id)
  end
end
