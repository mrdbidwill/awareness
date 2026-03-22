# frozen_string_literal: true

class InvitationTokenPolicy < ApplicationPolicy
  def index?
    user.present? && user.admin?
  end

  def new?
    user.present? && user.admin?
  end

  def create?
    user.present? && user.admin?
  end

  def destroy?
    user.present? && user.admin?
  end

  class Scope < Scope
    def resolve
      if user.present? && user.admin?
        scope.all
      else
        scope.none
      end
    end
  end
end
