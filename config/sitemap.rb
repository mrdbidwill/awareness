# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "https://#{ENV.fetch('APP_HOST', 'awareness.mrdbid.com')}"

SitemapGenerator::Sitemap.create do
  # Root path is added automatically

  # Static pages
  add '/terms', priority: 0.5, changefreq: 'monthly'
  add '/glossary', priority: 0.7, changefreq: 'weekly'
  add '/contact', priority: 0.5, changefreq: 'monthly'
  add new_newsletter_path, priority: 0.6, changefreq: 'monthly'

  # iNaturalist observation fields dataset - high priority for SEO
  add '/inaturalist/observation_fields', priority: 0.9, changefreq: 'monthly'

  # Main resources
  add mushrooms_path, priority: 0.8, changefreq: 'daily'
  add articles_path, priority: 0.7, changefreq: 'weekly'
  add archive_articles_path, priority: 0.7, changefreq: 'weekly'

  Subject.with_published_article_counts.each do |subject|
    add subject_articles_path(subject_slug: subject.slug), priority: 0.6, changefreq: 'weekly'
  end

  # Individual articles
  Article.find_each do |article|
    add article_path(article), lastmod: article.updated_at, priority: 0.6, changefreq: 'monthly'
  end

  # Public mushroom records (if publicly accessible)
  # Mushroom.find_each do |mushroom|
  #   add mushroom_path(mushroom), lastmod: mushroom.updated_at, priority: 0.5
  # end
end
