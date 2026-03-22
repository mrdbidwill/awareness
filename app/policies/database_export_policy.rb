# app/policies/database_export_policy.rb
class DatabaseExportPolicy < ApplicationPolicy
  def export?
    user.present? && user.admin? # Allow only users with admin rights
  end
end
