# Admin controller for managing universal projects
# Universal projects have user_id = nil and are available to all users
class Admin::ProjectsController < Admin::ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy]

  # GET /admin/projects
  def index
    authorize Project
    @projects = policy_scope(Project).includes(:user).order(:name)
  end

  # GET /admin/projects/1
  def show
    authorize @project
  end

  # GET /admin/projects/new
  def new
    @project = Project.new
    authorize @project
  end

  # GET /admin/projects/1/edit
  def edit
    authorize @project
  end

  # POST /admin/projects
  def create
    @project = Project.new(project_params)
    @project.user_id = nil  # Force universal project
    authorize @project

    if @project.save
      redirect_to admin_projects_path, notice: "Universal project '#{@project.name}' was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /admin/projects/1
  def update
    authorize @project
    if @project.update(project_params)
      redirect_to admin_projects_path, notice: "Project '#{@project.name}' was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /admin/projects/1
  def destroy
    authorize @project
    name = @project.name
    @project.destroy!
    redirect_to admin_projects_path, notice: "Project '#{name}' was successfully deleted."
  end

  private

  def set_project
    @project = Project.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:name, :description, :comments)
  end
end
