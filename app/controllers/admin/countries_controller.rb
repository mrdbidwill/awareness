class Admin::CountriesController < Admin::ApplicationController
  include Pundit::Authorization

  # GET /countries or /countries.json
  def index
    authorize Country
    # @countries = policy_scope(Country.order(:name))
    @countries = policy_scope(Country).includes(:states).order(:name)
  end

  # GET /countries/1 or /countries/1.json
  def show
    @country = Country.find(params[:id])
    authorize @country
  end


  # GET /countries/new
  def new
    @country = Country.new
    # Allow access to new action for signed-in users without ownership requirement
    authorize @country, :new?
  end

  # GET /countries/1/edit
  def edit
    @country = Country.find(params[:id])
    authorize @country
  end


  # POST /countries or /countries.json
  def create
    @country = Country.new(country_params)
    authorize @country
    if @country.save
      redirect_to admin_country_url(@country), notice: "Country was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /countries/1 or /countries/1.json
  def update
    @country = Country.find(params[:id])
    authorize @country
    if @country.update(country_params)
      redirect_to admin_country_url(@country), notice: "Country was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end


  # DELETE /countries/1 or /countries/1.json
  def destroy
    @country = Country.find(params[:id])
    authorize @country
    @country.destroy!
    redirect_to admin_countries_path, notice: "Country was successfully deleted."
  end


  private
  # Only allow a list of trusted parameters through.
  def country_params
    params.expect(country: [ :name, :description, :comments ])
  end
end
