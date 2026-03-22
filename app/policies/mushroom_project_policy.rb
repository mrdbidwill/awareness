class MushroomProjectPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.all if user&.elevated_admin?

      scope
        .joins(:project, :mushroom)
        .where(mushrooms: { user_id: user.id })
        .where("projects.user_id IS NULL OR projects.user_id = ?", user.id)
    end
  end

  # Reusable ownership logic via associations (project or mushroom)
  def owner_or_admin?
    return false unless user
    return true if user.elevated_admin?

    mushroom_owned = record.respond_to?(:mushroom) && record.mushroom&.user_id == user.id
    project = record.respond_to?(:project) ? record.project : nil
    project_allowed = project && (project.user_id.nil? || project.user_id == user.id)

    mushroom_owned && project_allowed
  end


  def new?
    user.present?
  end


  def create?
    owner_or_admin?
  end


  def index?
    user.present?
  end

  def show?
    owner_or_admin?
  end

  def edit?
    owner_or_admin?
  end

  def update?
    owner_or_admin?
  end

  def destroy?
    owner_or_admin?
  end
end
