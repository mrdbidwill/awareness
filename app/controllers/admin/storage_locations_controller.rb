class Admin::StorageLocationsController < Admin::ApplicationController
  include Pundit::Authorization

  # GET /storage_locations or /storage_locations.json
  def index
    @storage_locations = policy_scope(StorageLocation)
    respond_to do |format|
      format.html
    end
  end

  # GET /storage_locations/1 or /storage_locations/1.json
  def show
    @storage_location = StorageLocation.find(params[:id])
    authorize @storage_location
    respond_to do |format|
      format.html
    end
  end


  # GET /storage_locations/new
  def new
    @storage_location = StorageLocation.new
    # Allow access to new action for signed-in users without ownership requirement
    authorize @storage_location, :new?
    respond_to do |format|

      format.html
      format.json { render json: @storage_locations }
    end
  end

  # GET /storage_locations/1/edit
  def edit
    @storage_location = StorageLocation.find(params[:id])
    authorize @storage_location
    respond_to do |format|
      format.html
    end
  end


  # POST /storage_locations or /storage_locations.json
  def create
    @storage_location = StorageLocation.new(storage_location_params)
    authorize @storage_location
    if @storage_location.save
      redirect_to admin_storage_location_path(@storage_location), notice: "Storage Location was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /storage_locations/1 or /storage_locations/1.json
  def update
    @storage_location = StorageLocation.find(params[:id])
    authorize @storage_location
    if @storage_location.update(storage_location_params)
      redirect_to admin_storage_location_path(@storage_location), notice: "Storage Location was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end


  # DELETE /storage_locations/1 or /storage_locations/1.json
  def destroy
    @storage_location = StorageLocation.find(params[:id])
    authorize @storage_location
    @storage_location.destroy!
    redirect_to admin_storage_locations_path, notice: "Storage Location was successfully deleted."
  end


  private
  # Only allow a list of trusted parameters through.
  def storage_location_params
    params.expect(storage_location: [ :name, :description, :comments ])
  end
end
