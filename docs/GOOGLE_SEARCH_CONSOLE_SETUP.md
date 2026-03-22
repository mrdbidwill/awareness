# Google Search Console Setup Instructions

## What We've Set Up

✅ **Sitemap created** at `/public/sitemap.xml.gz` with 18 links including:
- iNaturalist observation fields page (priority 0.9 - highest)
- Main pages (home, glossary, articles, mushrooms, etc.)
- Individual article pages

✅ **robots.txt updated** to reference the sitemap

✅ **Auto-regeneration scheduled** - Run `rails sitemap:refresh` before deploying updates

---

## Step 1: Set Up Google Search Console

1. **Go to Google Search Console**
   - Visit: https://search.google.com/search-console

2. **Add Your Property**
   - Click "Add Property"
   - Choose "URL prefix" method
   - Enter: `https://mrdbid.com`
   - Click "Continue"

3. **Verify Ownership** (choose one method):

   **Option A: HTML File Upload** (Easiest)
   - Google will give you an HTML file to download
   - Save it to `public/` directory in your Rails app
   - Deploy/push to production
   - Click "Verify" in Google Search Console

   **Option B: HTML Tag** (Alternative)
   - Google will give you a meta tag
   - Add it to `app/views/layouts/application.html.erb` in the `<head>` section
   - Deploy/push to production
   - Click "Verify" in Google Search Console

   **Option C: DNS Record** (If you manage DNS)
   - Add TXT record to your domain's DNS
   - Click "Verify" in Google Search Console

---

## Step 2: Submit Your Sitemap

1. **After verification, go to "Sitemaps" in the left menu**

2. **Add new sitemap:**
   - Enter: `sitemap.xml.gz`
   - Click "Submit"

3. **Google will begin crawling your site**
   - You'll see status change from "Fetching" to "Success"
   - This can take a few hours to a few days

---

## Step 3: Request Indexing for Key Pages

To speed up indexing of your iNaturalist observation fields page:

1. **Go to "URL Inspection" in the left menu**

2. **Enter the full URL:**
   ```
   https://mrdbid.com/inaturalist/observation_fields
   ```

3. **Click "Request Indexing"**
   - Google will prioritize this page for crawling
   - Can take 1-2 days instead of weeks

4. **Repeat for other important pages** (optional):
   - Home page: `https://mrdbid.com`
   - Glossary: `https://mrdbid.com/glossary`
   - Articles: `https://mrdbid.com/articles`

---

## Step 4: Monitor Performance

After 1-2 weeks, check Google Search Console to see:

1. **Coverage Report**
   - Shows which pages are indexed
   - Alerts you to any errors

2. **Performance Report**
   - Shows which search queries bring users to your site
   - Click-through rates and impressions

3. **Enhancements**
   - Mobile usability issues
   - Core Web Vitals (page speed)

---

## Ongoing Maintenance

### When to Update Sitemap

Run this command **before deploying** whenever you:
- Add new articles
- Add new major features/pages
- Update the iNaturalist dataset

```bash
rails sitemap:refresh
git add public/sitemap.xml.gz
git commit -m "Update sitemap"
```

### Automatic Sitemap Updates (Optional)

Add to your deployment process or create a scheduled job:

**Capistrano** (in `config/deploy.rb`):
```ruby
after 'deploy:finishing', 'deploy:refresh_sitemap'

namespace :deploy do
  task :refresh_sitemap do
    on roles(:app) do
      within release_path do
        execute :rake, 'sitemap:refresh'
      end
    end
  end
end
```

**Cron job** (run weekly):
```bash
0 2 * * 0 cd /path/to/mrdbid && RAILS_ENV=production bundle exec rake sitemap:refresh
```

---

## Expected Timeline After Setup

| Timeframe | What Happens |
|-----------|-------------|
| Day 1 | Submit sitemap to Google Search Console |
| Day 1-2 | Request indexing for key pages |
| Day 2-7 | Google discovers and crawls your pages |
| Week 2-3 | Pages appear in Google Index (searchable by exact URL) |
| Month 1-2 | Pages start ranking for relevant keywords |
| Month 3-6 | Good ranking for terms like "inaturalist observation fields download" |

---

## Tips for Faster Indexing

1. ✅ **Link from your homepage** - Add link to iNaturalist page
2. ✅ **Write article** - Link to the dataset from an article
3. ✅ **Post to iNaturalist forum** - External link helps
4. ✅ **Share on social media** - Can trigger faster discovery
5. ✅ **Add internal links** - Link from related pages on your site

---

## Troubleshooting

**Problem:** Page not appearing in Google after 2 weeks

**Solutions:**
- Check Google Search Console → Coverage → Excluded pages
- Verify robots.txt allows crawling: `curl https://mrdbid.com/robots.txt`
- Verify sitemap is accessible: `curl https://mrdbid.com/sitemap.xml.gz`
- Request indexing again in URL Inspection tool
- Check for "noindex" meta tags (shouldn't have any)

**Problem:** Sitemap shows errors

**Solutions:**
- Run `rails sitemap:refresh` locally to test
- Check that all URLs in sitemap are accessible (200 status)
- Verify SSL certificate is valid (https)

---

## Resources

- Google Search Console: https://search.google.com/search-console
- Sitemap Protocol: https://www.sitemaps.org/
- Google's Sitemap Guide: https://developers.google.com/search/docs/crawling-indexing/sitemaps/overview
- sitemap_generator gem: https://github.com/kjvarga/sitemap_generator
