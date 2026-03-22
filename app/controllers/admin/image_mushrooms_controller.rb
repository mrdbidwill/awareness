class Admin::ImageMushroomsController < Admin::ApplicationController

  before_action :set_image_mushroom, only: %i[show edit update destroy]
  before_action :set_collections, only: [:new, :create, :edit, :update]


  def index
    authorize ImageMushroom
    @image_mushrooms = policy_scope(ImageMushroom.includes(:mushroom, :part, :camera_make, :camera_model, :lens).order(:image_name))
  end

  def show
    authorize @image_mushroom
  end

  def new
    @image_mushroom = ImageMushroom.new
    authorize @image_mushroom
  end

  def create
    # Build from top-level params; do not rely on current_user or nesting
    @image_mushroom = ImageMushroom.new(image_mushroom_params)
    authorize @image_mushroom
    # Accept optional mushroom_id provided outside nested route without touching the association
    if params[:mushroom_id].present? && @image_mushroom.mushroom_id.blank?
      @image_mushroom.mushroom_id = params[:mushroom_id]
    end

    if @image_mushroom.save
      redirect_to [:admin, @image_mushroom], notice: "Image successfully uploaded."
    else
      # Reload data for form rendering without touching associations
      @mushroom = Mushroom.find_by(id: @image_mushroom.mushroom_id)
      @parts = Part.all.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @image_mushroom
    @mushrooms = Mushroom.all
    @parts = Part.all
  end

  def update
    authorize @image_mushroom
    begin
      if @image_mushroom.update(image_mushroom_params)
        redirect_to [:admin, @image_mushroom], notice: 'Image Mushroom was successfully updated.'
      else
        redirect_to [:admin, @image_mushroom], alert: 'Changes could not be applied.'
      end
    rescue ActiveRecord::InvalidForeignKey, ActiveRecord::RecordInvalid
      redirect_to [:admin, @image_mushroom], alert: 'Invalid change ignored.'
    end
  end

  def destroy
    authorize @image_mushroom
    @image_mushroom.destroy
    redirect_to admin_image_mushrooms_url, notice: 'Image Mushroom was successfully deleted.'
  end

  private

  def set_collections
    @mushrooms = Mushroom.all.order(:name)
    @parts = Part.all.order(:name)
  end

  def set_image_mushroom
    # Eager load all associations used in views and disable strict loading for this record
    @image_mushroom = ImageMushroom.includes(:mushroom, :part).find(params[:id])
    @image_mushroom.strict_loading!(false) if @image_mushroom.respond_to?(:strict_loading!)
  end

  # Only allow a list of trusted parameters through.
  def image_mushroom_params
    params.require(:image_mushroom).permit(
      :mushroom_id,
      :part_id,
      :image_name,
      :image_file,   # Permit the new `image_file` attachment - Active Storage
      :image_width,
      :image_height,
      :lens,
      :exposure,
      :aperture,
      :iso,
      :camera_make,
      :camera_model
    )
  end
end
