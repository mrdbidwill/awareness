# app/policies/dna_sequence_policy.rb
class DnaSequencePolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      user&.admin? ? scope.all : scope.none
    end
  end

  def index?;   user&.admin?; end
  def show?;    user&.admin?; end
  def new?;     user&.admin?; end
  def create?;  user&.admin?; end
  def edit?;    user&.admin?; end
  def update?;  user&.admin?; end
  def destroy?; user&.admin?; end
end
