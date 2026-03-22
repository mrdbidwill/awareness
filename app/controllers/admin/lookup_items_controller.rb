# app/controllers/admin/lookup_items_controller.rb
class Admin::LookupItemsController < Admin::ApplicationController
  before_action :set_lookup_item, only: [:edit, :update, :destroy]

  def index
    authorize LookupItem

    # Search by character name or ID (independent of filters)
    if params[:q].present?
      term_raw = params[:q].to_s.strip
      term = ActiveRecord::Base.sanitize_sql_like(term_raw)

      # Find matching characters first
      matching_characters = if term_raw =~ /\A\d+\z/
        MrCharacter.where(id: term_raw.to_i)
      else
        MrCharacter.where("name LIKE ?", "%#{term}%")
      end

      matching_character_ids = matching_characters.pluck(:id)

      # Get lookup items for those characters (LEFT JOIN so characters without items still appear)
      @lookup_items = policy_scope(
        LookupItem.includes(:mr_character, :source_data)
          .where(mr_character_id: matching_character_ids)
          .order("mr_characters.name, lookup_items.name")
      ).joins(:mr_character)

      # Store matching characters for display (including those without items)
      @searched_characters = matching_characters.order(:name)
    else
      # Normal filtering/browsing mode
      @lookup_items = policy_scope(
        LookupItem.includes(:mr_character, :source_data)
          .joins(:mr_character)
          .order("mr_characters.name, lookup_items.name")
      )

      # Apply character filter only when NOT searching
      @lookup_items = @lookup_items.where(mr_character_id: params[:mr_character_id]) if params[:mr_character_id].present?
    end

    # Paginate (required for `paginate` helper)
    @lookup_items = @lookup_items.page(params[:page]).per(20)

    # Populate mr_characters dropdown - show ALL characters so admins can add lookup_items to new characters
    @mr_characters = MrCharacter.strict_loading(false).order(:name).pluck(:name, :id)
  end

  def new
    authorize LookupItem
    @lookup_item = LookupItem.new(mr_character_id: params[:mr_character_id])
    @mr_characters = MrCharacter.strict_loading(false).includes(:part).order(:name).to_a
  end

  def show
    authorize LookupItem
    @lookup_item = LookupItem.includes(:mr_character, :source_data).find(params[:id])
  end


  def create
    authorize LookupItem
    @lookup_item = LookupItem.new(lookup_item_params)
    if @lookup_item.save
      redirect_to admin_lookup_items_path, notice: "Lookup item created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @lookup_item
    @mr_characters = MrCharacter.strict_loading(false).includes(:part).order(:name).to_a
  end

  def update
    authorize @lookup_item
    if @lookup_item.update(lookup_item_params)
      # INLINE EDITING SUPPORT: Allow admins to edit lookup items from user workflows
      # When admins click edit icons (✏️) next to radio/dropdown options in mushroom edit views,
      # they are redirected here with a return_to param containing the originating page.
      # After successful save, redirect back to that page so admin can continue their work.
      #
      # Flow: Mushroom Edit → Click ✏️ on option → Edit Lookup Item → Save → Back to Mushroom Edit
      #
      # Example return_to: "/mushrooms/123/edit"
      # Falls back to admin index if return_to not provided (normal admin workflow)
      redirect_path = if params[:return_to].present?
        params[:return_to]
      else
        admin_lookup_items_path(mr_character_id: params[:mr_character_id], page: params[:page])
      end

      # CODING STANDARD: Use redirect_to with notice: and status: :see_other
      # per RAILS_8_TURBO_STANDARD_PATTERN.md - DO NOT use respond_to blocks
      redirect_to redirect_path, notice: "Lookup item updated successfully.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @lookup_item
    @lookup_item.destroy
    redirect_to admin_lookup_items_path, notice: "Lookup item deleted successfully."
  end

  def versions
    @lookup_item = LookupItem.find(params[:id])
    # Show most recent first
    @versions = @lookup_item.versions.order(created_at: :desc)
    authorize @lookup_item # Pundit: restricts to admins
  end

  private

  def set_lookup_item
    @lookup_item = LookupItem.find(params[:id])
  end

  def lookup_item_params
    params.require(:lookup_item).permit(:mr_character_id, :name, :description, :comments, :source_data_id)
  end
end
