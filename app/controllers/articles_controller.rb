class ArticlesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show archive], raise: false
  skip_after_action :verify_authorized, only: %i[index show archive], raise: false
  skip_after_action :verify_policy_scoped, only: %i[index archive], raise: false

  def index
    @selected_subject = find_subject_by_filter(params[:subject])
    @subjects = Subject.with_published_article_counts.order(:name)
    @articles = filtered_articles(subject: @selected_subject).page(params[:page]).per(10)
  end

  def archive
    @selected_subject = find_subject_by_filter(params[:subject_slug])
    @year = extract_year(params[:year])
    @month = extract_month(params[:month])

    @subjects = Subject.with_published_article_counts.order(:name)
    @archive_year_counts = archive_year_counts(subject: @selected_subject)
    @archive_month_counts = @year ? archive_month_counts(@year, subject: @selected_subject) : {}

    @articles = filtered_articles(
      subject: @selected_subject,
      year: @year,
      month: @month
    ).page(params[:page]).per(20)
  end

  def show
    @article = Article.published.includes(:subject, :user, article_source_citations: :source).find_by!(slug: params[:id])
  end

  private

  def filtered_articles(subject:, year: nil, month: nil)
    scope = Article.published.includes(:subject, :user)
    scope = scope.where(subject: subject) if subject.present?
    scope = scope.for_year(year) if year.present?
    scope = scope.for_month(year, month) if month.present?
    scope.recent
  end

  def find_subject_by_filter(filter)
    return nil if filter.blank?

    Subject.find_by(slug: filter) || Subject.find_by(name: filter)
  end

  def extract_year(raw_year)
    return nil if raw_year.blank?

    year = raw_year.to_i
    raise ActiveRecord::RecordNotFound unless year.between?(1900, 2200)

    year
  end

  def extract_month(raw_month)
    return nil if raw_month.blank?

    month = raw_month.to_i
    raise ActiveRecord::RecordNotFound unless month.between?(1, 12)

    month
  end

  def archive_year_counts(subject: nil)
    scope = Article.published
    scope = scope.where(subject: subject) if subject.present?

    scope.group(Arel.sql("YEAR(COALESCE(published_at, created_at))"))
           .order(Arel.sql("YEAR(COALESCE(published_at, created_at)) DESC"))
           .count
  end

  def archive_month_counts(year, subject: nil)
    scope = Article.published.where("YEAR(COALESCE(published_at, created_at)) = ?", year)
    scope = scope.where(subject: subject) if subject.present?

    scope.group(Arel.sql("MONTH(COALESCE(published_at, created_at))"))
         .order(Arel.sql("MONTH(COALESCE(published_at, created_at)) DESC"))
         .count
  end
end
