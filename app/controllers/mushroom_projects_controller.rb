# This controller manages the pivot table mushroom_projects between projects and mushrooms
#  which allows a user to add a mushroom object to a project

class MushroomProjectsController < ApplicationController
  include Pundit::Authorization

  before_action :authenticate_user!
  before_action :set_mushroom_project, only: %i[ show edit update destroy ]

  # Skip Pundit verification - authorization handled via ownership checks
  skip_after_action :verify_authorized, raise: false
  skip_after_action :verify_policy_scoped, only: [:index], raise: false

  def index
    @mushroom_projects = policy_scope(MushroomProject)
  end

  def show
    unless owns_mushroom_project?(@mushroom_project)
      redirect_to mushrooms_path, alert: "You can only view your own mushroom project associations."
      return
    end
  end

  def new
    @mushroom = Mushroom.find(params[:mushroom_id]) if params[:mushroom_id]
    @mushroom_project = MushroomProject.new(mushroom: @mushroom)
    @projects = policy_scope(Project, policy_scope_class: ProjectPolicy::SelectionScope)
    if @mushroom && !owns_mushroom?(@mushroom)
      redirect_to mushrooms_path, alert: "You can only add projects to your own mushrooms."
      return
    end
  end

  def create
    @mushroom_project = MushroomProject.new(mushroom_project_params)
    @mushroom = Mushroom.find_by(id: mushroom_project_params[:mushroom_id])
    @projects = policy_scope(Project, policy_scope_class: ProjectPolicy::SelectionScope)

    # Verify user owns the project they're trying to add to
    project = Project.find_by(id: mushroom_project_params[:project_id])
    unless project && project_available_to_user?(project)
      redirect_to mushrooms_path, alert: "You can only add mushrooms to your own or universal projects."
      return
    end

    # Verify user owns the mushroom they're trying to add
    unless owns_mushroom?(@mushroom)
      redirect_to mushrooms_path, alert: "You can only add your own mushrooms to projects."
      return
    end

    if @mushroom_project.save
      redirect_to mushrooms_path, notice: "Group was successfully added.", status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  end



  def edit
    unless owns_mushroom_project?(@mushroom_project)
      redirect_to mushrooms_path, alert: "You can only edit your own mushroom project associations."
      return
    end
  end

  def update
    unless owns_mushroom_project?(@mushroom_project)
      redirect_to mushrooms_path, alert: "You can only update your own mushroom project associations."
      return
    end

    if @mushroom_project.update(mushroom_project_params)
      redirect_to mushroom_project_path(@mushroom_project), notice: "All group mushroom was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end


  def destroy
    unless owns_mushroom_project?(@mushroom_project)
      redirect_to mushrooms_path, alert: "You can only delete your own mushroom project associations."
      return
    end

    @mushroom_project.destroy
    redirect_to mushrooms_path, notice: "The group was successfully removed.", status: :see_other
  end


  private

  # Use callbacks to share common setup or constraints between actions.
  def set_mushroom_project
    @mushroom_project = MushroomProject.find(params[:id])
  end


  # Only allow a list of trusted parameters through.
  def mushroom_project_params
    params.require(:mushroom_project).permit(
      :mushroom_id,
      :project_id
    )
  end

  def owns_mushroom?(mushroom)
    return false unless mushroom && current_user
    return true if current_user.elevated_admin?
    mushroom.user_id == current_user.id
  end

  def project_available_to_user?(project)
    return false unless project && current_user
    return true if current_user.elevated_admin?
    project.user_id.nil? || project.user_id == current_user.id
  end

  def owns_mushroom_project?(mushroom_project)
    return false unless mushroom_project && current_user
    return true if current_user.elevated_admin?
    owns_mushroom?(mushroom_project.mushroom) && project_available_to_user?(mushroom_project.project)
  end
end
