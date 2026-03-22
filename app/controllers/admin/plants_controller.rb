class Admin::PlantsController < Admin::ApplicationController
  before_action :set_plant, only: %i[show edit update destroy]

  # GET /plants
  def index
    authorize Plant
    @plants = policy_scope(Plant.order(:name))
  end

  # GET /plants/1
  def show
    authorize @plant
  end

  # GET /plants/new
  def new
    @plant = Plant.new
    authorize @plant
  end

  # POST /plants
  def create
    @plant = Plant.new(plant_params)
    authorize @plant
    if @plant.save
      redirect_to admin_plant_path(@plant), notice: "Camera make was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /plants/1/edit
  def edit
    authorize @plant
  end

  # PATCH/PUT /plants/1
  def update
    authorize @plant
    if @plant.update(plant_params)
      redirect_to admin_plant_path(@plant), notice: "Camera make was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /plants/1
  def destroy
    authorize @plant
    @plant.destroy!
    redirect_to admin_plants_path, notice: "Camera make was successfully deleted."
  end

  private

  def set_plant
    @plant = Plant.find(params.expect(:id))
  end

  def plant_params
    params.expect(plant: [:name, :description, :comments, :source])
  end
end
