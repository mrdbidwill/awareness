# test/models/article_test.rb
require "test_helper"

class ArticleTest < ActiveSupport::TestCase
  def setup
    @article = articles(:one)
  end

  test "should be valid with valid attributes" do
    assert @article.valid?
  end

  test "should require title" do
    article = Article.new(slug: "test", body: "Test body")
    assert_not article.valid?
    assert_includes article.errors[:title], "Title cannot be blank."
  end

  test "should auto-generate slug from title if blank" do
    article = Article.new(title: "Test Title", body: "Test body", slug: nil)
    article.valid?
    assert_equal "test-title", article.slug
  end

  test "should require body" do
    article = Article.new(title: "Test", slug: "test")
    assert_not article.valid?
    assert_includes article.errors[:body], "Body cannot be blank."
  end

  test "should require unique slug" do
    Article.create!(title: "Test", slug: "unique-slug", body: "Body", author_name: "Test Author")
    duplicate = Article.new(title: "Test 2", slug: "unique-slug", body: "Body 2")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:slug], "has already been taken"
  end

  test "should normalize slug before validation" do
    article = Article.new(title: "Test Article", body: "Body")
    article.valid?
    assert_equal "test-article", article.slug
  end

  test "should have published scope" do
    assert_respond_to Article, :published
  end

  test "should have by_subject_slug scope" do
    assert_respond_to Article, :by_subject_slug
  end

  test "should have recent scope" do
    assert_respond_to Article, :recent
  end

  test "to_param should return slug" do
    assert_equal @article.slug, @article.to_param
  end

  test "should have timestamps" do
    assert_not_nil @article.created_at
    assert_not_nil @article.updated_at
  end

  test "should require author_name when no user display name can be applied" do
    article = Article.new(title: "No Author", slug: "no-author", body: "Body")

    assert_not article.valid?
    assert article.errors[:author_name].any?
  end

  test "captures author_name from user display_name on create when blank" do
    user = users(:three)
    article = Article.create!(
      title: "Author Snapshot",
      slug: "author-snapshot",
      body: "Body",
      user: user
    )

    assert_equal "Admin User", article.author_name
  end

  test "preserves author_name snapshot if user display name changes later" do
    user = users(:three)
    article = Article.create!(
      title: "Author Snapshot Frozen",
      slug: "author-snapshot-frozen",
      body: "Body",
      user: user
    )
    user.update!(display_name: "Renamed Admin")

    assert_equal "Admin User", article.reload.author_name
    assert_equal "Admin User", article.display_author_name
  end
end
