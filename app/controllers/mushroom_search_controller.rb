class MushroomSearchController < ApplicationController
  before_action :authenticate_user!

  # Skip Pundit verification - uses policy_scope! inline
  skip_after_action :verify_authorized, raise: false
  skip_after_action :verify_policy_scoped, only: :index, raise: false

  def index
    @query = params[:q]
    @fungus_type_id = params[:fungus_type_id]

    # Convert new array format to hash format for query object
    @character_filters = if params[:character_ids].present? && params[:character_values].present?
      character_ids = params[:character_ids].reject(&:blank?)
      character_values = params[:character_values]
      character_ids.zip(character_values).to_h
    else
      {}
    end

    # Search across ALL mushrooms (not just current user's)
    all_mushrooms_scope = MushroomPolicy::Scope.new(current_user, Mushroom).resolve_all

    # Use query object for clean, testable search logic
    @mushrooms = MushroomSearchQuery.new(all_mushrooms_scope)
                   .non_templates
                   .search(@query)
                   .by_fungus_type(@fungus_type_id)
                   .by_characters(@character_filters)
                   .with_associations
                   .results
                   .page(params[:page])
                   .per(20)

    # Get available fungus types for filter dropdown
    @fungus_types = FungusType.order(:name)
  end

  # Autocomplete endpoint for characters
  def autocomplete_characters
    query = params[:q].to_s.strip

    characters = if query.present?
      MrCharacter
        .where(display_option_id: [2, 3, 4, 5, 6])
        .where("name LIKE ?", "%#{query}%")
        .order(:name)
        .limit(20)
    else
      MrCharacter.none
    end

    render json: characters.map { |c| { id: c.id, name: c.name.tr('_', ' ') } }
  end
end
