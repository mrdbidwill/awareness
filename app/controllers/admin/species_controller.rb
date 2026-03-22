class Admin::SpeciesController < Admin::ApplicationController
  before_action :set_species, only: %i[show edit update destroy]

  # GET /species
  def index
    authorize Species
    @species = policy_scope(Species.includes(:genus).order(:name))
  end

  # GET /speciess/1
  def show
    authorize @species
  end

  # GET /speciess/new
  def new
    @species = Species.new
    authorize @species
  end

  # POST /speciess
  def create
    @species = Species.new(species_params)
    authorize @species
    if @species.save
      redirect_to admin_species_path(@species), notice: "Species was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /speciess/1/edit
  def edit
    authorize @species
  end

  # PATCH/PUT /speciess/1
  def update
    authorize @species
    if @species.update(species_params)
      redirect_to admin_species_path(@species), notice: "Species was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /speciess/1
  def destroy
    authorize @species
    @species.destroy!
    redirect_to admin_species_index_path, notice: "Species was successfully deleted."
  end

  private

  def set_species
    @species = Species.includes(:mushroom_species, :genus).find(params.expect(:id))
  end

  def species_params
    params.expect(species: [:mblist_id, :name, :genera_id])
  end
end
