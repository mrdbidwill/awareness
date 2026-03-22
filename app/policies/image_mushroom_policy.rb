# app/policies/image_mushroom_policy.rb
class ImageMushroomPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      user&.admin? ? scope.all : scope.none
    end
  end

  def index?;   user&.admin?; end
  def show?
    return true if user.present?

    # Public visitors only see demo user's images (mushroom user_id == 1)
    record.mushroom&.user_id == 1
  end
  def new?;     owner_or_admin?; end
  def create?;  owner_or_admin?; end
  def edit?;    owner_or_admin?; end
  def update?;  owner_or_admin?; end
  def destroy?; owner_or_admin?; end

  private

  def owner_or_admin?
    return false unless user
    return true if user.elevated_admin?
    return false unless record.mushroom
    record.mushroom.user_id == user.id
  end
end
