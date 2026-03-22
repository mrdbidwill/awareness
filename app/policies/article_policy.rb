class ArticlePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      # Non-admins see none in /admin
      return scope.none unless user&.admin?

      # Owner sees all articles
      return scope.all if user.owner?

      # Admins (permission_id == 2) only see their own articles
      scope.where(user_id: user.id)
    end
  end

  def index?
    user&.admin?
  end

  def show?
    user&.admin?
  end

  def create?
    user&.admin?
  end

  def new?
    create?
  end

  def update?
    # Only owner (permission_id == 1) or admin (permission_id == 2) can edit
    # AND they must be the creator of the article
    return false unless user&.admin?
    return true if user.owner? # Owner can edit any article
    return false unless record.user_id.present?

    # Admin (permission_id == 2) can only edit their own articles
    user.permission_id == 2 && record.user_id == user.id
  end

  def edit?
    update?
  end

  def destroy?
    # Only owner (permission_id == 1) or admin (permission_id == 2) can delete
    # AND they must be the creator of the article
    return false unless user&.admin?
    return true if user.owner? # Owner can delete any article
    return false unless record.user_id.present?

    # Admin (permission_id == 2) can only delete their own articles
    user.permission_id == 2 && record.user_id == user.id
  end
end