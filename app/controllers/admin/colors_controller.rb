class Admin::ColorsController < Admin::ApplicationController
  before_action :set_color, only: %i[ show edit update destroy ]

  # GET /colors or /colors.json
  def index
    authorize Color
    @colors = policy_scope(Color.all_for_picker)
  end

  # GET /colors/1 or /colors/1.json
  def show
    authorize @color
  end

  # GET /colors/new
  def new
    @color = Color.new
    authorize @color
  end

  # POST /camera_makes
  def create
    @color = Color.new(color_params)
    authorize @color
    if @color.save
      redirect_to admin_color_path(@color), notice: "Color was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /colors/1/edit
  def edit
    authorize @color
  end

  # PATCH/PUT /colors/1
  def update
    authorize @color
    if @color.update(color_params)
      redirect_to admin_color_path(@color), notice: "Color was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /colors/1
  def destroy
    authorize @color
    @color.destroy!
    redirect_to admin_colors_path, notice: "Color was successfully deleted."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_color
      @color = Color.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
  def color_params
    params.expect(color: [
      :latin_name,
      :common_name,
      :color_group,
      :hex,
      :sequence,
      :r_val,
      :g_val,
      :b_val,
      :cwc_r,
      :cwc_g,
      :cwc_b,
      :closest_websafe_color,
      :image_file_address,
      :metadata
    ])
  end

end
