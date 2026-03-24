# frozen_string_literal: true

class Source < ApplicationRecord
  has_many :article_source_citations, dependent: :destroy, inverse_of: :source, strict_loading: false
  has_many :articles, through: :article_source_citations

  validates :name, presence: true
  validate :publish_year_format

  scope :recent_first, -> { order(publish_date: :desc, created_at: :desc) }
  scope :alphabetical_by_name, lambda {
    normalized_name_sql = "LOWER(TRIM(COALESCE(sources.name, '')))"
    stripped_name_sql = "REGEXP_REPLACE(#{normalized_name_sql}, '^(the|an|a)[[:space:][:punct:]]+', '')"
    order(Arel.sql("#{stripped_name_sql} ASC, #{normalized_name_sql} ASC, sources.id ASC"))
  }
  scope :search, lambda { |query|
    q = query.to_s.strip
    next all if q.blank?

    like = "%#{ActiveRecord::Base.sanitize_sql_like(q)}%"
    where(
      "sources.name LIKE :like OR sources.author LIKE :like OR sources.description LIKE :like",
      like: like
    )
  }

  before_validation :assign_publish_date_from_publish_year

  def publish_year
    @publish_year.presence || publish_date&.year&.to_s
  end

  def publish_year=(value)
    @publish_year = value.to_s.strip
  end

  private

  def assign_publish_date_from_publish_year
    return if @publish_year.nil?

    if @publish_year.blank?
      self.publish_date = nil
      return
    end

    return unless @publish_year.match?(/\A\d{4}\z/)

    self.publish_date = Date.new(@publish_year.to_i, 1, 1)
  end

  def publish_year_format
    return if @publish_year.nil? || @publish_year.blank?
    return if @publish_year.match?(/\A\d{4}\z/)

    errors.add(:publish_year, "must be a 4-digit year (YYYY)")
  end
end
