class FungusTypePolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      # Admins can see all; others can see all (or restrict if needed)
      scope.all
    end
  end

  # Keep if you still need it elsewhere
  def owner?
    record.user_id == user.id
  end

  def index?
    true
  end

  def show?
    true
  end

  def new?
    user.admin?
  end

  def create?
    user.admin?
  end

  def edit?
    user.admin?
  end

  def update?
    user.admin?
  end

  def destroy?
    # If you also need a deletable guard, keep it; otherwise just user.admin?
    user.admin? && (!record.respond_to?(:can_be_deleted?) || record.can_be_deleted?)
  end
end