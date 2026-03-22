# app/controllers/admin/mr_characters_controller.rb
class Admin::MrCharactersController < Admin::ApplicationController
  before_action :set_mr_character, only: [:show, :edit, :update, :destroy]

  def index
    authorize MrCharacter
    @mr_characters = policy_scope(
      MrCharacter
        .includes( :part, :observation_method, :display_option, :source_data, :fungus_type)
        .order(:name)  # change order here to modify default sort order
    )

    # Search by name or ID (independent of filters)
    if params[:q].present?
      term_raw = params[:q].to_s.strip
      term = ActiveRecord::Base.sanitize_sql_like(term_raw)
      if term_raw =~ /\A\d+\z/
        @mr_characters = @mr_characters.where("mr_characters.id = ?", term_raw.to_i)
      else
        @mr_characters = @mr_characters.where("mr_characters.name LIKE ?", "%#{term}%")
      end
    else
      # Apply filters only when NOT searching
      @mr_characters = @mr_characters.where(part_id: params[:part_id]) if params[:part_id].present?

      # Filter by observation method
      if params[:observation_method_id].present?
        if params[:observation_method_id] == 'universal'
          @mr_characters = @mr_characters.where(observation_method_id: nil)
        else
          @mr_characters = @mr_characters.where(observation_method_id: params[:observation_method_id])
        end
      end

      # Filter by fungus type
      if params[:fungus_type_id].present?
        if params[:fungus_type_id] == 'universal'
          @mr_characters = @mr_characters.where(fungus_type_id: nil)
        else
          @mr_characters = @mr_characters.where(fungus_type_id: params[:fungus_type_id])
        end
      end

      # Filter by needs_review status
      if params[:needs_review].present?
        @mr_characters = @mr_characters.where(needs_review: params[:needs_review] == 'true')
      end
    end

    # Paginate (required for `paginate` helper)
    @mr_characters = @mr_characters.page(params[:page]).per(20)

    # Populate parts dropdown (all parts)
    @parts = Part.order(:name).pluck(:name, :id)

    # Populate observation_methods dropdown (filtered by part if selected)
    @observation_methods =
      if params[:part_id].present?
        ObservationMethod.joins(:mr_characters)
                  .where(mr_characters: { part_id: params[:part_id] })
                  .distinct
                  .order(:name)
                  .pluck(:name, :id)
      else
        ObservationMethod.order(:name).pluck(:name, :id)
      end

    # Populate fungus_types dropdown
    @fungus_types = FungusType.order(:name).pluck(:name, :id)
  end

  def new
    authorize MrCharacter
    @mr_character = MrCharacter.new
  end

  def create
    authorize MrCharacter
    @mr_character = MrCharacter.new(mr_character_params)
    if @mr_character.save
      redirect_to admin_mr_characters_path, notice: "Character created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @mr_character
  end

  def show
    @mr_character = MrCharacter
                      .includes(:part, :observation_method, :display_option, :fungus_type,:source_data)
                      .find(params.expect(:id))
    authorize @mr_character
  end


  def update
    authorize @mr_character
    if @mr_character.update(mr_character_params)
      # INLINE EDITING SUPPORT: Allow admins to edit characters from user workflows
      # When admins click edit icons (⚙️) next to characters in mushroom edit views,
      # they are redirected here with a return_to param containing the originating page.
      # After successful save, redirect back to that page so admin can continue their work.
      #
      # Flow: Mushroom Edit → Click ⚙️ → Edit Character → Save → Back to Mushroom Edit
      #
      # Example return_to: "/mushrooms/123/edit"
      # Falls back to admin index if return_to not provided (normal admin workflow)
      redirect_path = if params[:return_to].present?
        params[:return_to]
      else
        admin_mr_characters_path(page: params[:page])
      end

      # CODING STANDARD: Use redirect_to with notice: and status: :see_other
      # per RAILS_8_TURBO_STANDARD_PATTERN.md - DO NOT use respond_to blocks
      redirect_to redirect_path, notice: "Character updated successfully.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize MrCharacter
    @mr_character.destroy
    redirect_to admin_mr_characters_path, notice: "Character deleted successfully."
  end

  private

  def set_mr_character
    @mr_character = MrCharacter.includes(:mr_character_mushrooms, :fungus_type, :lookup_items, :source_data).find(params[:id])
  end

  def mr_character_params
    params.require(:mr_character).permit(:name, :description, :comments, :part_id, :observation_method_id, :display_option_id, :source_data_id, :source_data_title, :fungus_type_id, :needs_review, :core)
  end
end
