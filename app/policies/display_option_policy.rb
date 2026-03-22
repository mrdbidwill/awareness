class DisplayOptionPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end

  # Reusable ownership logic
  def owner?
  end

  def new?
    user.admin?
  end


  def create?
    user.admin?
  end

  def index?
    true # Everyone can access the index
  end

  def show?
    true
  end

  def edit?
    user.admin?
  end

  def update?
    user.admin?
  end

  def destroy?
    user.admin?
  end
end