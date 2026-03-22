class Admin::SourceDataTypesController < Admin::ApplicationController
  before_action :set_source_data_type, only: %i[show edit update destroy]

  # GET /source_data_types
  def index
    authorize SourceDataType
    @source_data_types = policy_scope(SourceDataType.order(:name))
  end

  # GET /source_data_types/1
  def show
    authorize @source_data_type
  end

  # GET /source_data_types/new
  def new
    @source_data_type = SourceDataType.new
    authorize @source_data_type
  end

  # POST /source_data_types
  def create
    @source_data_type = SourceDataType.new(source_data_type_params)
    authorize @source_data_type
    if @source_data_type.save
      redirect_to admin_source_data_type_path(@source_data_type), notice: "Source data  type was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /source_data_types/1/edit
  def edit
    authorize @source_data_type
  end

  # PATCH/PUT /source_data_types/1
  def update
    authorize @source_data_type
    if @source_data_type.update(source_data_type_params)
      redirect_to admin_source_data_type_path(@source_data_type), notice: "Source data  type was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /source_data_types/1
  def destroy
    authorize @source_data_type
    @source_data_type.destroy!
    redirect_to admin_source_data_types_path, notice: "Source data  type was successfully deleted."
  end

  private

  def set_source_data_type
    @source_data_type = SourceDataType.find(params.expect(:id))
  end

  def source_data_type_params
    params.expect(source_data_type: [ :name, :description, :comments ])
  end
end
