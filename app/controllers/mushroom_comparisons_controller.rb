# frozen_string_literal: true

class MushroomComparisonsController < ApplicationController
  # ============================================================================
  # MUSHROOM COMPARISONS CONTROLLER
  # ============================================================================
  # Manages comparison operations between mushrooms based on character traits.
  #
  # AUTHENTICATION & AUTHORIZATION:
  # - Uses Devise for authentication (authenticate_user!)
  # - Users can compare any mushroom (regardless of ownership)
  #
  # PERFORMANCE NOTES:
  # - Comparisons run asynchronously via CompareMushroomsJob
  # - Uses pagination for comparison results
  # - Eager loads associations to prevent N+1 queries
  #
  # KEY ACTIONS:
  # - index: Shows all comparisons for a specific mushroom
  # - show: Shows details of a single comparison
  # - create: Triggers comparison job for a mushroom
  # ============================================================================

  include Pundit::Authorization

  before_action :authenticate_user!
  before_action :set_mushroom, only: [:index, :create]

  # Skip Pundit verification - authorization handled via authentication and record lookup
  skip_after_action :verify_authorized, raise: false
  skip_after_action :verify_policy_scoped, only: :index, raise: false

  # GET /mushrooms/:mushroom_id/comparisons
  def index
    # Check if mushroom has minimum characters
    @character_count = @mushroom.mr_character_mushrooms.count
    @minimum_characters = CompareMushroomsJob::MINIMUM_CHARACTERS

    if @character_count < @minimum_characters
      flash.now[:alert] = "This mushroom needs at least #{@minimum_characters} characters for meaningful comparison. Currently has #{@character_count}."
      @comparisons = []
      return
    end

    # Get all completed comparisons for this mushroom, sorted by similarity
    @comparisons = MushroomComparison
                     .includes(compared_mushroom: [:user, :fungus_type])
                     .for_mushroom(@mushroom.id)
                     .completed
                     .by_similarity
                     .page(params[:page])
                     .per(25)

    # Check for pending comparisons
    @pending_count = MushroomComparison.for_mushroom(@mushroom.id).pending.count
  end

  # GET /mushroom_comparisons/:id
  def show
    @comparison = MushroomComparison
                    .includes(:mushroom, :compared_mushroom)
                    .find(params[:id])

    # Load character details for both mushrooms to show matching/non-matching characters
    @mushroom_characters = load_mushroom_characters(@comparison.mushroom)
    @compared_characters = load_mushroom_characters(@comparison.compared_mushroom)
  end

  # POST /mushrooms/:mushroom_id/comparisons
  def create
    # Check if mushroom has minimum characters
    character_count = @mushroom.mr_character_mushrooms.count
    minimum_characters = CompareMushroomsJob::MINIMUM_CHARACTERS

    if character_count < minimum_characters
      redirect_to mushroom_path(@mushroom),
                  alert: "Mushroom needs at least #{minimum_characters} characters for comparison. Currently has #{character_count}."
      return
    end

    # Enqueue comparison job
    CompareMushroomsJob.perform_later(@mushroom.id)

    redirect_to mushroom_mushroom_comparisons_path(mushroom_id: @mushroom.id),
                notice: "Comparison started. This may take a few minutes. Refresh to see results."
  end

  private

  def set_mushroom
    @mushroom = Mushroom.find(params[:mushroom_id])
  end

  def load_mushroom_characters(mushroom)
    # Returns array of hashes with character details
    mushroom.mr_character_mushrooms
            .includes(mr_character: [:part, :display_option])
            .map do |mcm|
      {
        id: mcm.mr_character_id,
        name: mcm.mr_character.name,
        part: mcm.mr_character.part.name,
        value: mcm.character_value
      }
    end
  end
end
