class Admin::PartsController < Admin::ApplicationController
  before_action :set_part, only: %i[show edit update destroy]

  # GET /parts
  def index
    authorize Part
    @parts = policy_scope(Part.order(:name))
  end

  # GET /parts/1
  def show
    authorize @part
  end

  # GET /parts/new
  def new
    @part = Part.new
    authorize @part
  end

  # POST /parts
  def create
    @part = Part.new(part_params)
    authorize @part
    if @part.save
      redirect_to admin_part_path(@part), notice: "Part was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /parts/1/edit
  def edit
    authorize @part
  end

  # PATCH/PUT /parts/1
  def update
    authorize @part
    if @part.update(part_params)
      redirect_to admin_part_path(@part), notice: "Part was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /parts/1
  def destroy
    authorize @part
    @part.destroy!
    redirect_to admin_parts_path, notice: "Part was successfully deleted."
  end

  private

  def set_part
    @part = Part.find(params.expect(:id))
  end

  def part_params
    params.expect(part: [:name, :description, :comments, :source])
  end
end
