class GenusMushroomPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.all if user&.elevated_admin?
      scope.joins(:mushroom).where(mushrooms: { user_id: user.id })
    end
  end

  def owner_or_admin?
    return false unless user
    return true if user.elevated_admin?
    record.mushroom&.user_id == user.id
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

  def update?
    owner_or_admin?
  end

  def destroy?
    owner_or_admin?
  end
end
