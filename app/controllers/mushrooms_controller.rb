class MushroomsController < ApplicationController
  # ============================================================================
  # MUSHROOMS CONTROLLER - User's Personal Mushroom Collection Management
  # ============================================================================
  # This controller manages CRUD operations for mushrooms owned by individual users.
  # Each mushroom belongs to a single user (see app/models/mushroom.rb).
  #
  # AUTHENTICATION & AUTHORIZATION:
  # - Uses Devise for authentication (authenticate_user!)
  # - Uses Pundit for authorization (see app/policies/mushroom_policy.rb)
  # - Users can only edit/delete their own mushrooms (or admin override)
  # - Signed-in users can view any mushrooms; public users only see demo content
  #
  # PERFORMANCE NOTES:
  # - Uses eager loading to prevent N+1 queries
  # - Index action uses pagination (25 items per page via Kaminari)
  # - All queries include necessary associations to avoid multiple DB calls
  #
  # ⚠️  CRITICAL AUTHORIZATION FLOW:
  # 1. authenticate_user! runs first (except index - allows public viewing of empty list)
  # 2. set_mushroom loads the record for show/edit/update/destroy
  # 3. authorize_mushroom checks Pundit policy (user must own the mushroom)
  # ============================================================================

  # Pundit setup
  include Pundit::Authorization

  before_action :authenticate_user!, except: [:index, :show] # Allow public to view index and show for demo
  before_action :set_mushroom, only: %i[show edit update destroy edit_characters clone_characters]
  before_action :authorize_mushroom, except: %i[index show new create clone_characters]

  # Skip Pundit verification for public actions (index when not logged in, and show)
  # and actions where authorization is handled by service objects
  skip_after_action :verify_authorized, only: [:create, :clone_characters], raise: false
  skip_after_action :verify_policy_scoped, only: [:index], if: -> { !user_signed_in? }, raise: false

  # GET /mushrooms
  def index
    if user_signed_in?
      # ============================================================================
      # EAGER LOADING - CRITICAL FOR RAILS 8 STRICT_LOADING
      # ============================================================================
      # Must include ALL associations used in views to prevent StrictLoadingViolationError
      # - fungus_type: Used for grouping and display
      # - country, state: Used for location display
      # - genera, species: Used for scientific name display
      # - image_mushrooms.image_file_attachment.blob: For rendering images
      # - image_mushrooms.part: Used in _image_card partial (lines 10, 15) for alt text
      #
      # ⚠️  WARNING: Adding associations to views? Update this includes!
      # Missing associations cause 500 errors in production due to strict_loading.
      # ============================================================================

      @mushrooms = policy_scope(Mushroom)

      # Search by name, description, comments, city, genus (minimum 3 characters)
      if params[:q].present? && params[:q].strip.length >= 3
        term_raw = params[:q].to_s.strip
        term = ActiveRecord::Base.sanitize_sql_like(term_raw)
        if term_raw =~ /\A\d+\z/
          # Exact ID match
          @mushrooms = @mushrooms.where("mushrooms.id = ?", term_raw.to_i)
        else
          # Search across multiple fields
          @mushrooms = @mushrooms
            .left_joins(:genera)
            .where(
              "mushrooms.name LIKE ? OR mushrooms.description LIKE ? OR mushrooms.comments LIKE ? OR mushrooms.city LIKE ? OR genera.name LIKE ?",
              "%#{term}%", "%#{term}%", "%#{term}%", "%#{term}%", "%#{term}%"
            )
            .distinct
        end
      end

      @mushrooms = @mushrooms
                     .includes(:user, :fungus_type, :country, :state, :genera, { species: :genus },
                               :clusters, :all_groups, :projects,
                               image_mushrooms: [:part, { image_file_attachment: :blob }])
                     .left_joins(:fungus_type)
                     .select('mushrooms.*', 'fungus_types.name as fungus_type_name')
                     .order(Arel.sql('fungus_types.name IS NULL'), 'fungus_types.name', 'mushrooms.name')
                     .page(params[:page])
                     .per(12)
    else
      # Show user_id 1's mushrooms to public visitors to demonstrate the site
      @mushrooms = Mushroom.where(user_id: 1)

      # Search by name, description, comments, city, genus (minimum 3 characters)
      if params[:q].present? && params[:q].strip.length >= 3
        term_raw = params[:q].to_s.strip
        term = ActiveRecord::Base.sanitize_sql_like(term_raw)
        if term_raw =~ /\A\d+\z/
          # Exact ID match
          @mushrooms = @mushrooms.where("mushrooms.id = ?", term_raw.to_i)
        else
          # Search across multiple fields
          @mushrooms = @mushrooms
            .left_joins(:genera)
            .where(
              "mushrooms.name LIKE ? OR mushrooms.description LIKE ? OR mushrooms.comments LIKE ? OR mushrooms.city LIKE ? OR genera.name LIKE ?",
              "%#{term}%", "%#{term}%", "%#{term}%", "%#{term}%", "%#{term}%"
            )
            .distinct
        end
      end

      @mushrooms = @mushrooms
                     .includes(:fungus_type, :country, :state, :genera, { species: :genus },
                               :clusters, :all_groups, :projects,
                               image_mushrooms: [:part, { image_file_attachment: :blob }])
                     .left_joins(:fungus_type)
                     .select('mushrooms.*', 'fungus_types.name as fungus_type_name')
                     .order(Arel.sql('fungus_types.name IS NULL'), 'fungus_types.name', 'mushrooms.name')
                     .page(params[:page])
                     .per(12)
    end
  end

  # GET /mushrooms/1 or /mushrooms/1.json
  def show
    authorize @mushroom
  end

  # GET /mushrooms/new
  def new
    @mushroom = Mushroom.new

    # Set collection date to today by default
    @mushroom.collection_date = Date.today

    # If copying location from another mushroom, use that mushroom's location
    if params[:copy_location_from].present?
      source_mushroom = current_user.mushrooms.find_by(id: params[:copy_location_from])
      if source_mushroom
        @mushroom.country_id = source_mushroom.country_id
        @mushroom.state_id = source_mushroom.state_id
        @mushroom.city = source_mushroom.city
        @mushroom.county = source_mushroom.county
      end
    # Otherwise, pre-populate with user's default location preferences if set
    elsif current_user.default_country_id.present?
      @mushroom.country_id = current_user.default_country_id
      @mushroom.state_id = current_user.default_state_id if current_user.default_state_id.present?
      @mushroom.city = current_user.default_city if current_user.default_city.present?
      @mushroom.county = current_user.default_county if current_user.default_county.present?
    end

    authorize @mushroom
  end

  # POST /mushrooms or /mushrooms.json
  def create
    result = Mushrooms::Creator.call(
      user: current_user,
      params: mushroom_params.except(:user_id)
    )

    if result.success?
      redirect_to new_image_mushroom_path(mushroom_id: result.data.id), notice: "Mushroom was successfully created. Now add an image.", status: :see_other
    else
      # result.data contains the mushroom object (even on failure) for form re-render
      @mushroom = result.data || Mushroom.new(mushroom_params.except(:user_id))
      render :new, status: :unprocessable_entity
    end
  end

  # GET /mushrooms/1/edit
  def edit
    # set_mushroom before_action already loads the mushroom with basic associations
    # authorize_mushroom before_action already checks authorization
    # Reload with additional associations needed for edit view
    # CRITICAL: species must include genus association for ranked_identifications display
    @mushroom = Mushroom
                  .includes(:genera, { species: :genus }, :trees, :plants, :fungus_type,
                            :clusters, :all_groups, :projects,
                            :cluster_mushrooms, :all_group_mushrooms, :mushroom_projects,
                            image_mushrooms: [:part, { image_file_attachment: :blob }],
                            mr_character_mushrooms: { mr_character: [:part, :display_option, :source_data] })
                  .find(params[:id])

    # Check if fungus_type exists (data integrity check)
    if @mushroom.fungus_type.nil?
      Rails.logger.error("Mushroom #{@mushroom.id} has invalid fungus_type_id: #{@mushroom.fungus_type_id}")
      redirect_to mushrooms_path, alert: "Cannot edit mushroom: invalid fungus type. Please contact an administrator."
      return
    end
  rescue ActiveRecord::RecordNotFound
      redirect_to mushrooms_path, alert: "Mushroom not found."
  end

  # GET /mushrooms/1/edit_characters?observation_method_id=X&part_id=Y
  def edit_characters
    @observation_method = ObservationMethod.find(params[:observation_method_id])
    @part = Part.find(params[:part_id])
    @core_only = params[:core_only].to_s != "false"

    # Get all characters for this observation_method + part combination
    # Filter by fungus_type if set (includes universal characters with fungus_type_id = NULL)
    base_scope = if @mushroom.fungus_type_id.present?
                   MrCharacter
                     .for_fungus_type(@mushroom.fungus_type_id)
                     .where(observation_method: @observation_method, part: @part)
                 else
                   MrCharacter
                     .where(observation_method: @observation_method, part: @part)
                 end

    all_chars = base_scope.includes(:display_option, :source_data, :lookup_items).order(:name).to_a
    @all_characters_count = all_chars.size
    core_chars_for_context = MrCharacter.select_core_for_display(all_chars, fungus_type_id: @mushroom.fungus_type_id)
    @core_characters_count = core_chars_for_context.size

    if @core_only
      core_chars = core_chars_for_context
      if core_chars.any?
        @characters = MrCharacter.sort_for_core_display(core_chars, keep_part_order: false, fungus_type_id: @mushroom.fungus_type_id)
      else
        @characters = all_chars
        @core_fallback = true
      end
    else
      @characters = all_chars
    end

    authorize @mushroom
  rescue ActiveRecord::RecordNotFound => e
    redirect_to edit_mushroom_path(@mushroom), alert: "#{e.message}"
  end


  # PATCH/PUT /mushrooms/1 or /mushrooms/1.json
  def update
    result = Mushrooms::Updater.call(
      user: current_user,
      mushroom: @mushroom,
      params: mushroom_params.except(:user_id)
    )

    if result.success?
      redirect_to result.data, notice: "Mushroom was successfully updated.", status: :see_other
    else
      # Reload with eager loading for edit form associations
      @mushroom = Mushroom.includes(
        :image_mushrooms,
        :fungus_type,
        :clusters,
        :all_groups,
        :projects,
        :cluster_mushrooms,
        :all_group_mushrooms,
        :mushroom_projects,
        mr_characters: [:part, :observation_method, :color, :source_data]
      ).find(@mushroom.id)
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /mushrooms/1 or /mushrooms/1.json
  def destroy
    result = Mushrooms::Destroyer.call(user: current_user, mushroom: @mushroom)

    if result.success?
      redirect_to mushrooms_path, notice: "Mushroom was successfully deleted.", status: :see_other
    else
      redirect_to @mushroom, alert: result.error
    end
  end

  # POST /mushrooms/:id/clone_characters
  def clone_characters
    if params[:source_mushroom_id].blank?
      redirect_to edit_mushroom_path(@mushroom), alert: 'Please select a mushroom to clone from.'
      return
    end

    source_mushroom = Mushroom.includes(:mr_character_mushrooms).find(params[:source_mushroom_id])

    result = Mushrooms::CharacterCloner.call(
      user: current_user,
      source_mushroom: source_mushroom,
      target_mushroom: @mushroom
    )

    if result.success?
      count = result.data[:count]
      redirect_to edit_mushroom_path(@mushroom),
                  notice: "Successfully cloned #{count} characters from #{source_mushroom.name}."
    else
      redirect_to edit_mushroom_path(@mushroom), alert: result.error
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to edit_mushroom_path(@mushroom), alert: 'Source mushroom not found.'
  end

  private

  # ============================================================================
  # set_mushroom - Loads mushroom with all necessary associations
  # ============================================================================
  # Called by before_action for: show, edit, update, destroy
  #
  # ASSOCIATIONS PRELOADED (prevents N+1 queries):
  # - country, state, fungus_type: Basic metadata
  # - genera, species: Taxonomic classification
  # - trees, plants: Associated flora
  # - image_mushrooms: Photos attached to this mushroom
  # - image_mushrooms.image_file_attachment.blob: Active Storage blob data
  #
  # SECURITY: Pundit authorization runs after loading to verify user ownership
  #
  # ERROR HANDLING: Redirects to index if mushroom doesn't exist (not 404)
  # ============================================================================
  def set_mushroom
    @mushroom = Mushroom
                  .includes(:country, :state, :fungus_type, :genera, { species: :genus }, :trees, :plants,
                            :clusters, :all_groups, :projects,
                            :cluster_mushrooms, :all_group_mushrooms, :mushroom_projects,
                            image_mushrooms: { image_file_attachment: :blob })
                  .find(params[:id])
    # Authorization is handled by authorize_mushroom before_action
  rescue ActiveRecord::RecordNotFound
    redirect_to mushrooms_path, alert: "Mushroom not found."
  end

  # ============================================================================
  # mushroom_params - Strong parameters for mass assignment protection
  # ============================================================================
  # SECURITY NOTES:
  # - :user_id is permitted here BUT is filtered out in create/update actions
  # - This prevents users from assigning mushrooms to other users
  # - Country, state, fungus_type are foreign keys (validated by model)
  #
  # ⚠️  WARNING: Do NOT remove :user_id from the permit list - it's intentionally
  # filtered in the controller actions (see create and update methods)
  # ============================================================================
  def mushroom_params
    params.require(:mushroom).permit(:name, :description, :comments, :personal_notes, :user_id, :country_id, :state_id, :city, :county, :fungus_type_id, :collection_date)
  end

  # ============================================================================
  # authorize_mushroom - Pundit authorization check
  # ============================================================================
  # Ensures the current user has permission to perform the requested action.
  # Called by before_action for: show, edit, update, destroy
  #
  # POLICY RULES (see app/policies/mushroom_policy.rb):
  # - Users can only view/edit/delete their own mushrooms
  # - Admin users have additional privileges (if implemented)
  #
  # ERRORS: Pundit::NotAuthorizedError is rescued by ApplicationController
  # ============================================================================
  def authorize_mushroom
    authorize @mushroom
  end
end
