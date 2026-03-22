require "test_helper"

class ArticlesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @article = articles(:one)
    @article.update!(published: true, published_at: Time.current)
  end

  test "should get index without authentication" do
    get articles_url
    assert_response :success
  end

  test "should get index with subject filter" do
    get articles_url, params: { subject: @article.subject.slug }
    assert_response :success
  end

  test "should show published article without authentication" do
    get article_url(@article)
    assert_response :success
  end

  test "should find article by slug" do
    article_with_slug = Article.create!(
      title: "Slug Test",
      slug: "slug-test-public",
      body: "Content",
      published: true,
      published_at: Time.current
    )

    get article_url(article_with_slug.slug)
    assert_response :success
  end

  test "should not show unpublished article" do
    unpublished = Article.create!(
      title: "Unpublished",
      slug: "unpublished",
      body: "Content",
      subject: subjects(:mycology),
      published: false
    )

    get article_url(unpublished.slug)
    assert_response :not_found
  end

  test "should paginate articles" do
    get articles_url, params: { page: 1 }
    assert_response :success
  end

  test "should display subjects list" do
    get articles_url
    assert_response :success
    assert_not_nil assigns(:subjects)
  end

  test "should get archive index" do
    get archive_articles_url
    assert_response :success
  end

  test "should filter archive by subject slug" do
    get subject_articles_url(subject_slug: subjects(:mycology).slug)
    assert_response :success
  end

  test "should filter archive by year and month" do
    published_date = @article.published_at.to_date
    get archive_month_articles_url(year: published_date.year, month: published_date.month)
    assert_response :success
  end
end
