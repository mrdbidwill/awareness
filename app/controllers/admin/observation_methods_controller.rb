class Admin::ObservationMethodsController < Admin::ApplicationController
  before_action :set_observation_method, only: %i[ show edit update destroy ]

  # GET /observation_methods
  def index
    authorize ObservationMethod
    @observation_methods = policy_scope(ObservationMethod.order(:name))
  end

  # GET /observation_methods/1
  def show
    authorize @observation_method
  end

  # GET /observation_methods/new
  def new
    @observation_method = ObservationMethod.new
    authorize @observation_method
  end

  # POST /observation_methods
  def create
    @observation_method = ObservationMethod.new(observation_method_params)
    authorize @observation_method
    if @observation_method.save
      redirect_to admin_observation_method_path(@observation_method), notice: "Observation method was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /observation_methods/1/edit
  def edit
    authorize @observation_method
  end

  # PATCH/PUT /observation_methods/1
  def update
    authorize @observation_method
    if @observation_method.update(observation_method_params)
      redirect_to admin_observation_method_path(@observation_method), notice: "Observation Method was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /observation_methods/1
  def destroy
    authorize @observation_method
    @observation_method.destroy!
    redirect_to admin_observation_methods_path, notice: "Observation method was successfully deleted."
  end

  private

  def set_observation_method
    @observation_method = ObservationMethod.find(params.expect(:id))
  end

  def observation_method_params
    params.expect(observation_method: [:name, :description, :comments, :source])
  end
end
