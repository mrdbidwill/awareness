class PagesController < ApplicationController
  skip_before_action :authenticate_user!, raise: false
  skip_after_action :verify_authorized, raise: false

  def home
    published_articles = Article.published.includes(:subject).recent
    @featured_article = published_articles.first
    @latest_articles = published_articles.offset(1).limit(6)
    @subject_counts = Subject.with_published_article_counts
                             .order(Arel.sql("COUNT(articles.id) DESC"), :name)
    @newsletter_subscriber = NewsletterSubscriber.new
  end

  def terms
  end
end
