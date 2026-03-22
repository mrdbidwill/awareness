class CountryPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      # Admins can see all; others can see all (or restrict if needed)
      scope.all
    end
  end

  def owner?
  end

  def index?
    true
  end

  def show?
    true
  end

  def new?
    user.present? && user.admin?
  end

  def create?
    user.present? && user.admin?
  end

  def edit?
    user.present? && user.admin?
  end

  def update?
    user.present? && user.admin?
  end

  def destroy?
    user.present? && user.admin? && (!record.respond_to?(:can_be_deleted?) || record.can_be_deleted?)
  end
end
