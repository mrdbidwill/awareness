class Article < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :subject, optional: true
  has_many :article_source_citations, -> { ordered }, dependent: :destroy, inverse_of: :article, strict_loading: false
  has_many :sources, through: :article_source_citations

  validates :title, :slug, :body, :author_name, presence: true
  validates :slug, uniqueness: true

  # Keep slugs URL-friendly
  before_validation :normalize_slug
  before_validation :assign_author_name_from_user
  accepts_nested_attributes_for :article_source_citations, allow_destroy: true,
                                                         reject_if: :article_source_citation_blank?

  scope :published, -> { where(published: true).where("published_at IS NULL OR published_at <= ?", Time.current) }
  scope :recent, -> { order(Arel.sql("COALESCE(published_at, created_at) DESC"), created_at: :desc) }
  scope :by_subject_slug, lambda { |slug|
    next all if slug.blank?

    joins(:subject).where(subjects: { slug: slug })
  }
  scope :for_year, lambda { |year|
    next all if year.blank?

    y = year.to_i
    start_date = Time.zone.local(y, 1, 1)
    where("COALESCE(published_at, created_at) BETWEEN ? AND ?", start_date, start_date.end_of_year)
  }
  scope :for_month, lambda { |year, month|
    next all if year.blank? || month.blank?

    y = year.to_i
    m = month.to_i
    start_date = Time.zone.local(y, m, 1)
    where("COALESCE(published_at, created_at) BETWEEN ? AND ?", start_date, start_date.end_of_month)
  }

  def to_param
    slug
  end

  def publication_time
    published_at || created_at
  end

  def display_author_name
    author_name.presence || user&.display_name.presence || "Unknown author"
  end

  private

  def normalize_slug
    self.slug = (slug.presence || title.to_s).parameterize
  end

  def assign_author_name_from_user
    return if author_name.present?

    self.author_name = user&.display_name.presence
  end

  def article_source_citation_blank?(attributes)
    attributes["source_id"].blank? && attributes["page_locator"].blank? && attributes["note"].blank?
  end
end
