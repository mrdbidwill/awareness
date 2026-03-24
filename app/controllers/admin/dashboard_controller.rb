# app/controllers/admin/dashboard_controller.rb
class Admin::DashboardController < Admin::ApplicationController
  skip_after_action :verify_policy_scoped, only: :index, raise: false
  # Skip Pundit verification - dashboard shows aggregate stats, no specific resource authorization needed
  skip_after_action :verify_authorized, raise: false

  def index
    @users_count = User.count
    @published_articles_count = Article.published.count
    @newsletter_subscribers_count = NewsletterSubscriber.subscribed.count
    @subjects_count = Subject.count
    @sources_count = Source.count
  end
end
