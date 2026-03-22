class Article < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :subject, optional: true

  validates :title, :slug, :body, presence: true
  validates :slug, uniqueness: true

  # Keep slugs URL-friendly
  before_validation :normalize_slug

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

  private

  def normalize_slug
    self.slug = (slug.presence || title.to_s).parameterize
  end
end
