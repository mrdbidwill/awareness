class Subject < ApplicationRecord
  has_many :articles, dependent: :nullify

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :slug, presence: true, uniqueness: true

  before_validation :normalize_slug

  scope :alphabetical, -> { order(:name) }

  def to_param
    slug
  end

  def to_s
    name
  end

  def articles_count
    self[:articles_count].to_i
  end

  def self.with_published_article_counts
    joins(:articles)
      .merge(Article.published)
      .select("subjects.*, COUNT(articles.id) AS articles_count")
      .group("subjects.id")
  end

  private

  def normalize_slug
    self.slug = (slug.presence || name.to_s).parameterize
  end
end
