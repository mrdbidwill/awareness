# app/policies/admin_policy.rb
class AdminPolicy < ApplicationPolicy
  def access?
    user.present? && user.admin? # Allow only users with admin rights
  end
end