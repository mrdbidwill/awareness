class ImageMushroomsController < ApplicationController

  include Pundit::Authorization
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_image_mushroom, only: %i[show edit update destroy]

  # Skip Pundit verification for public index when not authenticated
  skip_after_action :verify_policy_scoped, only: [:index], if: -> { !user_signed_in? }, raise: false

  def index
    if user_signed_in?
      @image_mushrooms = policy_scope(ImageMushroom).includes(:mushroom, :part)
    else
      # Public visitors see demo user's images (user_id 1)
      @image_mushrooms = ImageMushroom.joins(:mushroom).where(mushrooms: { user_id: 1 }).includes(:mushroom, :part)
    end
  end


  def show
    authorize @image_mushroom

    # Get all images for this mushroom in the same order as shown on the mushroom page
    mushroom = @image_mushroom.mushroom
    all_images = mushroom.image_mushrooms.select { |im| im.image_file.attached? }
    current_index = all_images.index(@image_mushroom)

    if current_index
      @prev_image = all_images[current_index - 1] if current_index > 0
      @next_image = all_images[current_index + 1] if current_index < all_images.length - 1
    end
  end

  def new
    @mushroom = Mushroom.find_by(id: params[:mushroom_id]) # Optional mushroom from params
    unless @mushroom
      skip_authorization
      redirect_to mushrooms_path, alert: "You must choose a mushroom first." and return
    end
    authorize @mushroom, :mushroom_image_mushroom?
    @image_mushroom = ImageMushroom.new
    @image_mushroom.mushroom_id = @mushroom.id
    @parts = Part.all.order(:name)
  end


  def create
    @image_mushroom = ImageMushroom.new(image_mushroom_params)

    # Prefer nested route param, else fall back to hidden field
    route_parent_id = params[:mushroom_id].presence
    form_parent_id  = image_mushroom_params[:mushroom_id].presence
    parent_id = route_parent_id || form_parent_id

    if parent_id.blank?
      skip_authorization
      redirect_to mushrooms_path, alert: "You must choose a mushroom first." and return
    end

    @image_mushroom.mushroom_id = parent_id

    @mushroom = Mushroom.find_by(id: @image_mushroom.mushroom_id)

    begin
      authorize @mushroom, :mushroom_image_mushroom? if @mushroom
    rescue Pundit::NotAuthorizedError
      redirect_to root_path, alert: "You are not authorized to perform this action." and return
    end

    if @image_mushroom.save
      redirect_to mushroom_path(@image_mushroom.mushroom_id), notice: "Image successfully uploaded."
    else
      @parts = Part.all.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @image_mushroom
    @mushrooms = current_user&.elevated_admin? ? Mushroom.all : Mushroom.where(user_id: current_user.id)
    @parts = Part.all
  end

  def update
    authorize @image_mushroom
    new_mushroom_id = image_mushroom_params[:mushroom_id].presence
    if new_mushroom_id && new_mushroom_id.to_i != @image_mushroom.mushroom_id
      new_mushroom = Mushroom.find_by(id: new_mushroom_id)
      unless new_mushroom && (current_user&.elevated_admin? || new_mushroom.user_id == current_user.id)
        redirect_to edit_mushroom_image_mushroom_path(@image_mushroom.mushroom_id, @image_mushroom),
                    alert: "You can only move images to your own mushrooms."
        return
      end
    end
    begin
      if @image_mushroom.update(image_mushroom_params)
        mushroom = Mushroom.find(@image_mushroom.mushroom_id)
        redirect_to edit_mushroom_path(mushroom), notice: 'Image was successfully updated.'
      else
        @mushrooms = current_user&.elevated_admin? ? Mushroom.all : Mushroom.where(user_id: current_user.id)
        @parts = Part.all
        # Reload to get association after failed update
        @image_mushroom.reload unless @image_mushroom.mushroom_id.nil?
        render :edit, status: :unprocessable_entity
      end
    rescue ActiveRecord::InvalidForeignKey, ActiveRecord::RecordInvalid
      @mushrooms = current_user&.elevated_admin? ? Mushroom.all : Mushroom.where(user_id: current_user.id)
      @parts = Part.all
      # Reload to get association after failed update
      @image_mushroom.reload unless @image_mushroom.mushroom_id.nil?
      render :edit, status: :unprocessable_entity, alert: 'Invalid change ignored.'
    end
  end


  def destroy
    authorize @image_mushroom
    parent_id = @image_mushroom.mushroom_id
    @image_mushroom.destroy

    redirect_path = parent_id ? mushroom_path(parent_id) : image_mushrooms_path
    redirect_to redirect_path, notice: 'Image was successfully deleted.', status: :see_other
  end

  private

  def set_image_mushroom
    # Eager load all associations used in views and disable strict loading for this record
    @image_mushroom = ImageMushroom.includes(mushroom: :image_mushrooms).includes(:part, :camera_make, :camera_model, :lens).find(params[:id])
    @image_mushroom.strict_loading!(false) if @image_mushroom.respond_to?(:strict_loading!)
  end

  # Only allow a list of trusted parameters through.
  def image_mushroom_params
    params.require(:image_mushroom).permit(
      :mushroom_id,
      :part_id,
      :image_name,
      :image_width,
      :image_height,
      :image_file,
      :lens,
      :exposure,
      :aperture,
      :iso,
      :camera_make,
      :camera_model,
      :comments,
      :camera_make_id,
      :camera_model_id,
      :lens_id,
      :date_taken
    )
  end
end
