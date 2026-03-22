class Admin::PermissionsController < Admin::ApplicationController
  before_action :set_permission, only: %i[show edit update destroy]

  # GET /permissions
  def index
    authorize Permission
    @permissions = policy_scope(Permission.order(:name))
  end

  # GET /permissions/1
  def show
    authorize @permission
  end

  # GET /permissions/new
  def new
    @permission = Permission.new
    authorize @permission
  end

  # POST /permissions
  def create
    @permission = Permission.new(permission_params)
    authorize @permission
    if @permission.save
      redirect_to admin_permission_path(@permission), notice: "Camera make was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /permissions/1/edit
  def edit
    authorize @permission
  end

  # PATCH/PUT /permissions/1
  def update
    authorize @permission
    if @permission.update(permission_params)
      redirect_to admin_permission_path(@permission), notice: "Camera make was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /permissions/1
  def destroy
    authorize @permission
    @permission.destroy!
    redirect_to admin_permissions_path, notice: "Camera make was successfully deleted."
  end

  private

  def set_permission
    @permission = Permission.find(params.expect(:id))
  end

  def permission_params
    params.expect(permission: [:name, :description, :comments, :source])
  end
end
