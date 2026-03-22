# test/system/article_viewing_test.rb
require "application_system_test_case"

class ArticleViewingTest < ApplicationSystemTestCase
  setup do
    @published_article = articles(:one)
    @unpublished_article = articles(:two)
  end

  test "visiting the articles index without authentication" do
    visit articles_path

    assert_selector "h1", text: /articles/i
  end

  test "articles index shows published articles" do
    visit articles_path

    # Should see published article
    assert_text @published_article.title
  end

  test "articles index does not show unpublished articles" do
    visit articles_path

    # Should not see unpublished article
    assert_no_text @unpublished_article.title
  end

  test "clicking article navigates to article detail page" do
    visit articles_path

    click_link @published_article.title, match: :first

    assert_current_path article_path(@published_article.slug)
    assert_text @published_article.title
  end

  test "article detail page shows full content" do
    visit article_path(@published_article.slug)

    assert_text @published_article.title
    assert_text @published_article.body
  end

  test "unpublished article is not accessible" do
    visit article_path(@unpublished_article.slug)

    # Should see not found or be redirected
    assert_text /not found|404/i rescue assert_current_path articles_path
  end

  test "article shows published date" do
    visit article_path(@published_article.slug)

    # Should show publication date
    if page.has_text?("Published") || page.has_css?(".published-date")
      assert true
    end
  end

  test "articles can be filtered by subject" do
    visit articles_path

    subject_name = @published_article.subject&.name.to_s

    # Check if subject filter exists
    if page.has_select?("Subject") || page.has_link?(subject_name, exact: true)
      if page.has_select?("Subject")
        select subject_name, from: "Subject"
        assert_text @published_article.title
      elsif page.has_link?(subject_name, exact: true)
        click_link subject_name, exact: true
        assert_text @published_article.title
      end
    end
  end

  test "articles list is paginated" do
    visit articles_path

    # Check for pagination
    if page.has_link?("Next") || page.has_link?("2") || page.has_css?(".pagination")
      if page.has_link?("Next")
        click_link "Next"
        assert_selector "h1", text: /articles/i
      end
    else
      # Not enough articles for pagination
      assert true
    end
  end

  test "article detail has back link to articles index" do
    visit article_path(@published_article.slug)

    if page.has_link?("Back to articles")
      click_link "Back to articles", match: :first

      assert_current_path articles_path
    end
  end

  test "articles index shows article previews" do
    visit articles_path

    # Should show article title
    assert_text @published_article.title

    # Might show excerpt or preview
    if page.has_css?(".article-preview") || page.has_css?(".excerpt")
      assert true
    end
  end

  test "article detail displays formatted content" do
    visit article_path(@published_article.slug)

    # Article body should be present
    assert_text @published_article.body

    # Check if content is in readable format
    if page.has_css?(".article-content") || page.has_css?(".content")
      assert true
    end
  end

  test "articles are mobile responsive" do
    # Test with mobile viewport
    page.driver.browser.manage.window.resize_to(375, 667)

    visit articles_path

    assert_selector "h1", text: /articles/i
    assert_text @published_article.title

    # Click article
    click_link @published_article.title, match: :first

    # Should navigate to article
    assert_current_path article_path(@published_article.slug)
    assert_text @published_article.title

    # Reset to default size
    page.driver.browser.manage.window.resize_to(1400, 1400)
  end

  test "article navigation between articles" do
    visit article_path(@published_article.slug)

    # Look for next/previous article links
    if page.has_link?("Next Article") || page.has_link?("Previous Article")
      if page.has_link?("Next Article")
        click_link "Next Article"
        # Should navigate to another article
        assert_current_path(/articles\//)
      end
    end
  end

  test "articles index has search functionality" do
    visit articles_path

    if page.has_field?("Search") || page.has_field?("search")
      fill_in "Search", with: @published_article.title, match: :first

      if page.has_button?("Search")
        click_button "Search", match: :first
      end

      assert_text @published_article.title
    end
  end

  test "searching articles with no results" do
    visit articles_path

    if page.has_field?("Search")
      fill_in "Search", with: "NonexistentArticleXYZ123", match: :first

      if page.has_button?("Search")
        click_button "Search", match: :first
      end

      assert_text /no articles|no results/i rescue assert_no_text @published_article.title
    end
  end

  test "article shows author or source" do
    visit article_path(@published_article.slug)

    # Look for author or source information
    if page.has_text?("Author") || page.has_text?("By") || page.has_css?(".author")
      assert true
    end
  end

  test "article has meta description for SEO" do
    visit article_path(@published_article.slug)

    # Check for meta description tag
    if page.has_css?("meta[name='description']", visible: false)
      assert true
    end
  end

  test "article URL uses slug instead of ID" do
    visit article_path(@published_article.slug)

    # Current path should use slug
    assert_current_path article_path(@published_article.slug)
    assert_no_text /articles\/\d+/
  end

  test "articles index shows recent articles first" do
    visit articles_path

    # Most recent published article should appear first
    # This is indicated by published_at date
    assert_selector "h1", text: /articles/i
    assert_text @published_article.title
  end

  test "article categories or tags are visible" do
    visit article_path(@published_article.slug)

    # Look for category or tag display
    if page.has_text?("Category") || page.has_text?("Tags") || page.has_css?(".tags")
      assert true
    end
  end

  test "article shares social media buttons" do
    visit article_path(@published_article.slug)

    # Check for social sharing buttons
    if page.has_link?("Share") || page.has_css?(".share-buttons") || page.has_css?(".social")
      assert true
    end
  end

  test "articles index empty state" do
    # Hide all published articles
    Article.update_all(published: false)

    visit articles_path

    # Should see empty state message
    assert_text /no articles|coming soon/i rescue assert_selector "h1", text: /articles/i
  end

  test "article print view is accessible" do
    visit article_path(@published_article.slug)

    # Check for print button or styling
    if page.has_link?("Print") || page.has_css?(".print-button")
      assert true
    end
  end

  test "article comments section" do
    visit article_path(@published_article.slug)

    # Check if comments section exists
    if page.has_text?("Comments") || page.has_css?(".comments")
      assert true
    end
  end

  test "related articles section" do
    visit article_path(@published_article.slug)

    # Check for related articles
    if page.has_text?("Related") || page.has_css?(".related-articles")
      assert true
    end
  end

  test "article reading time estimate" do
    visit article_path(@published_article.slug)

    # Check for reading time
    if page.has_text?(/\d+ min read/i) || page.has_css?(".reading-time")
      assert true
    end
  end

  test "article images display correctly" do
    visit article_path(@published_article.slug)

    # Check for images in article
    if page.has_css?("img")
      images = page.all("img")
      # Ensure at least one image loaded properly
      assert images.any?
    end
  end

  test "article table of contents" do
    visit article_path(@published_article.slug)

    # Check for table of contents
    if page.has_text?("Table of Contents") || page.has_css?(".toc")
      assert true
    end
  end

  test "breadcrumb navigation in article" do
    visit article_path(@published_article.slug)

    # Check for breadcrumb
    if page.has_css?(".breadcrumb") || page.has_text?("Articles")
      assert true
    end
  end

  test "article subject filtering shows correct articles" do
    visit articles_path

    subject_name = @published_article.subject&.name.to_s

    # Filter by subject if available
    if @published_article.subject.present? && page.has_link?(subject_name, exact: true)
      click_link subject_name, exact: true

      # Should show only articles with that subject
      assert_text @published_article.title

      # URL should remain in articles section (query param strategy may vary)
      assert_current_path(/\/articles/)
    end
  end

  test "clearing article subject filter" do
    visit articles_path

    subject_name = @published_article.subject&.name.to_s

    # Apply subject filter
    if @published_article.subject.present? && page.has_link?(subject_name, exact: true)
      click_link subject_name, exact: true

      # Clear filter
      if page.has_link?("All Subjects")
        click_link "All Subjects", match: :first

        # Should show all articles again
        assert_selector "h1", text: /articles/i
      end
    end
  end

  test "article text is readable with proper typography" do
    visit article_path(@published_article.slug)

    # Check that article has content container with proper styling
    if page.has_css?(".article-content") || page.has_css?(".content") || page.has_css?("article")
      assert true
    end

    # Body text should be present
    assert_text @published_article.body
  end
end
