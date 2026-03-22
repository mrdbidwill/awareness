class ClusterPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      # Return only user-owned records
      scope.where(user_id: user.id)
    end
  end

  # Reusable ownership logic
  def owner?
    record.user_id == user.id
  end

  def new?
    true
  end


  def create?
    owner? # Reuse ownership logic
  end

  def index?
    true # Everyone can access the index
  end

  def show?
    owner? # Reuse ownership logic
  end

  def edit?
    owner? # Reuse ownership logic
  end

  def update?
    edit? # Reuse `edit?` for update permissions
  end

  def destroy?
    owner?
  end
end