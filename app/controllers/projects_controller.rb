# app/controllers/admin/projects_controller.rb
class ProjectsController < ApplicationController
  include Pundit::Authorization

  before_action :set_project, only: %i[ show edit update destroy ]

  # GET /projects
  def index
    @projects = policy_scope(Project)
  end


  # GET /projects/1
  def show
    @project = authorize current_user.projects.find(params[:id])
    respond_to do |format|

      format.html
      format.json { render json: @projects }
    end
  end



  # GET /projects/new
  def new
    @project = Project.new
    authorize @project, :new?
  end

  # GET /projects/1/edit
  def edit
    @project = authorize current_user.projects.find(params[:id])
    respond_to do |format|

      format.html
      format.json { render json: @projects }
    end
  end


  # POST /projects
  def create
    @project = current_user.projects.build(project_params)
    authorize @project
    if @project.save
      redirect_to project_url(@project), notice: "Project was successfully created.", status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /projects/1
  def update
    authorize @project
    if @project.update(project_params)
      redirect_to @project, notice: "Project was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end


  # DELETE /projects/1
  def destroy
    authorize @project
    @project.destroy!
    redirect_to projects_path, notice: "Project was successfully deleted.", status: :see_other
  end



  private

  def set_project
    @project = current_user.projects.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to projects_path, alert: "Project not found. You can only edit or show your own projects."
  end


  # Only allow a list of trusted parameters through.
  def project_params
    params.expect(project: [ :name, :description, :comments ])
  end
  end

