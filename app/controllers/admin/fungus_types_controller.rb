class Admin::FungusTypesController < Admin::ApplicationController
  before_action :set_fungus_type, only: %i[show edit update destroy]

  # GET /fungus_types
  def index
    authorize FungusType
    @fungus_types = policy_scope(FungusType.order(:name))
  end

  # GET /fungus_types/1
  def show
    authorize @fungus_type
  end

  # GET /fungus_types/new
  def new
    @fungus_type = FungusType.new
    authorize @fungus_type
  end

  # POST /fungus_types
  def create
    @fungus_type = FungusType.new(fungus_type_params)
    authorize @fungus_type
    if @fungus_type.save
      redirect_to admin_fungus_type_path(@fungus_type), notice: "Fungus type was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /fungus_types/1/edit
  def edit
    authorize @fungus_type
  end

  # PATCH/PUT /fungus_types/1
  def update
    authorize @fungus_type
    if @fungus_type.update(fungus_type_params)
      redirect_to admin_fungus_type_path(@fungus_type), notice: "Fungus type was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /fungus_types/1
  def destroy
    authorize @fungus_type
    @fungus_type.destroy!
    redirect_to admin_fungus_types_path, notice: "Fungus type was successfully deleted."
  end

  private

  def set_fungus_type
    @fungus_type = FungusType.find(params.expect(:id))
  end

  def fungus_type_params
    params.expect(fungus_type: [:name, :description, :comments, :source])
  end
end