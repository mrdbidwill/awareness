class Admin::LensesController < Admin::ApplicationController
  before_action :set_lens, only: %i[show edit update destroy]
  def index
    authorize Lens
    @lenses = policy_scope(Lens.all)
  end

  def show
    authorize @lens = Lens.find(params[:id])
  end

  def new
    @lens = Lens.new

  end

  def create
    @lens = Lens.new(lens_params)
    authorize @lens
    if @lens.save
      redirect_to admin_lenses_path, notice: "Lens successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @lens = Lens.find(params[:id])
    authorize @lens
  end

  def update
    @lens = Lens.find(params[:id])
    authorize @lens
    if @lens.update(lens_params)
      redirect_to admin_lenses_path, notice: "Lens successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @lens = Lens.find(params[:id])
    authorize @lens
    @lens.destroy
    redirect_to admin_lenses_path, notice: "Lens successfully deleted."
  end

  private
  def set_lens
    @lens = Lens.find(params.expect(:id))
  end

  def lens_params
    params.require(:lens).permit(:make, :model, :description, :comments)
  end
end