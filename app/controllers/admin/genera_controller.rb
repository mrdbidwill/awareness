class Admin::GeneraController < Admin::ApplicationController
  before_action :set_genus, only: %i[show edit update destroy]

  # GET /genera
  def index
    authorize Genus
    @genera = policy_scope(Genus.order(:name))
  end

  # GET /genera/1
  def show
    authorize @genus
  end

  # GET /genera/new
  def new
    @genus = Genus.new
    authorize @genus
  end

  # POST /genera
  def create
    @genus = Genus.new(genus_params)
    authorize @genus
    if @genus.save
      redirect_to admin_genus_path(@genus), notice: "Genus was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /genera/1/edit
  def edit
    authorize @genus
  end

  # PATCH/PUT /genera/1
  def update
    authorize @genus
    if @genus.update(genus_params)
      redirect_to admin_genus_path(@genus), notice: "Genus was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /genera/1
  def destroy
    authorize @genus
    @genus.destroy!
    redirect_to admin_genera_path, notice: "Genus was successfully deleted."
  end

  private

  def set_genus
    @genus = Genus.includes(:genus_mushrooms, :species).find(params.expect(:id))
  end

  def genus_params
    params.expect(genus: [:mblist_id, :name])
  end
end