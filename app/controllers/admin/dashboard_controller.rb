# app/controllers/admin/dashboard_controller.rb
class Admin::DashboardController < Admin::ApplicationController
  skip_after_action :verify_policy_scoped, only: :index, raise: false
  # Skip Pundit verification - dashboard shows aggregate stats, no specific resource authorization needed
  skip_after_action :verify_authorized, raise: false

  def index
    @mr_character_count = MrCharacter.count
    @lookup_item_count = LookupItem.count
    @source_data_count = SourceData.count
    @last_updated = MrCharacter.order(updated_at: :desc).first
  end
end
