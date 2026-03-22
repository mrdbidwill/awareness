class NewsletterCampaignPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      return scope.none unless user&.admin?
      return scope.all if user.owner?

      scope.where(user_id: user.id)
    end
  end

  def index?
    user&.admin?
  end

  def show?
    admin_owner_or_creator?
  end

  def create?
    user&.admin?
  end

  def new?
    create?
  end

  def update?
    admin_owner_or_creator? && record.draft?
  end

  def edit?
    update?
  end

  def destroy?
    admin_owner_or_creator?
  end

  def queue_delivery?
    admin_owner_or_creator? && record.draft?
  end

  private

  def admin_owner_or_creator?
    return false unless user&.admin?
    return true if user.owner?

    record.user_id == user.id
  end
end
