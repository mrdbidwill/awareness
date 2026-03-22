class ProjectPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.none unless user
      return scope.all if user.admin?

      # Users can only see their own projects in the index
      scope.where(user_id: user.id)
    end
  end

  # Scope for selecting projects to attach to mushrooms
  class SelectionScope < Scope
    def resolve
      # All projects are available for attachment to mushrooms
      scope.all
    end
  end

  # Reusable ownership logic
  def owner?
    user.present? && record.user_id == user.id
  end

  def admin?
    user&.admin?
  end

  def new?
    true
  end

  def create?
    admin? || owner? # Reuse ownership logic
  end

  def index?
    true # Everyone can access the index
  end

  def show?
    admin? || owner? # Reuse ownership logic
  end

  def edit?
    admin? || owner? # Reuse ownership logic
  end

  def update?
    edit? # Reuse `edit?` for update permissions
  end

  def destroy?
    (admin? || owner?) && record.can_be_deleted? # Additional condition for delete
  end
end
