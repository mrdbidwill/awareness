require "test_helper"

class Admin::ArticlesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @article = articles(:one)
    @owner_user = users(:one)  # permission_id: 1
    @admin_user = users(:three)  # permission_id: 2
  end

  test "should get index as admin" do
    sign_in @admin_user
    get admin_articles_url
    assert_response :success
  end

  test "owner sees all articles in index" do
    sign_in @owner_user
    article_by_owner = Article.create!(title: "Owner Article Index", slug: "owner-article-index", body: "Content", user: @owner_user)
    article_by_admin = Article.create!(title: "Admin Article Index", slug: "admin-article-index", body: "Content", user: @admin_user)

    get admin_articles_url
    assert_response :success
    assert_select "body", text: /Owner Article Index/
    assert_select "body", text: /Admin Article Index/
  end

  test "admin sees only their own articles in index" do
    sign_in @admin_user
    article_by_admin = Article.create!(title: "My Admin Article", slug: "my-admin-article-index", body: "Content", user: @admin_user)
    article_by_owner = Article.create!(title: "Owner Article Index 2", slug: "owner-article-index-2", body: "Content", user: @owner_user)

    get admin_articles_url
    assert_response :success
    assert_select "body", text: /My Admin Article/
    assert_select "body", text: /Owner Article Index 2/, count: 0
  end

  test "should get new as admin" do
    sign_in @admin_user
    get new_admin_article_url
    assert_response :success
  end

  test "should create article with current_user as owner" do
    sign_in @admin_user
    assert_difference("Article.count") do
      post admin_articles_url, params: {
        article: {
          title: "New Article",
          slug: "new-article",
          subject_id: subjects(:mycology).id,
          summary: "Summary",
          body: "Body content",
          published: false
        }
      }
    end

    assert_redirected_to admin_article_url(Article.last)
    assert_equal "Article created.", flash[:notice]
    assert_equal @admin_user.id, Article.last.user_id
  end

  test "should show preview when preview param is present" do
    sign_in @admin_user
    post admin_articles_url, params: {
      preview: "1",
      article: {
        title: "Preview Article",
        slug: "preview-article",
        body: "Preview content"
      }
    }

    assert_response :success
    assert_template :preview
  end

  test "should show article as admin" do
    sign_in @admin_user
    get admin_article_url(@article)
    assert_response :success
  end

  test "owner can edit any article" do
    sign_in @owner_user
    article_by_admin = Article.create!(
      title: "Admin Article for Owner Edit",
      slug: "admin-article-owner-edit",
      body: "Content",
      user: @admin_user
    )

    get edit_admin_article_url(article_by_admin)
    assert_response :success
  end

  test "admin can edit their own article" do
    sign_in @admin_user
    article = Article.create!(
      title: "My Article for Edit",
      slug: "my-article-edit",
      body: "Content",
      user: @admin_user
    )

    get edit_admin_article_url(article)
    assert_response :success
  end

  test "admin cannot edit article created by owner" do
    sign_in @admin_user
    article_by_owner = Article.create!(
      title: "Owner Article Edit Test",
      slug: "owner-article-edit-test",
      body: "Content",
      user: @owner_user
    )

    get edit_admin_article_url(article_by_owner)
    assert_redirected_to root_path
    assert_equal "You are not authorized to access this area.", flash[:alert]
  end

  test "owner can update any article" do
    sign_in @owner_user
    article_by_admin = Article.create!(
      title: "Admin Article for Owner Update",
      slug: "admin-article-owner-update",
      body: "Content",
      user: @admin_user
    )

    patch admin_article_url(article_by_admin), params: {
      article: { title: "Updated by Owner" }
    }

    assert_redirected_to admin_article_url(article_by_admin)
    assert_equal "Article updated.", flash[:notice]
  end

  test "admin can update their own article" do
    sign_in @admin_user
    article = Article.create!(
      title: "My Article for Update",
      slug: "my-article-update",
      body: "Content",
      user: @admin_user
    )

    patch admin_article_url(article), params: {
      article: { title: "Updated Title" }
    }

    assert_redirected_to admin_article_url(article)
    assert_equal "Article updated.", flash[:notice]
  end

  test "admin cannot update article created by owner" do
    sign_in @admin_user
    article_by_owner = Article.create!(
      title: "Owner Article Update Test",
      slug: "owner-article-update-test",
      body: "Content",
      user: @owner_user
    )

    patch admin_article_url(article_by_owner), params: {
      article: { title: "Attempted Update" }
    }
    assert_redirected_to root_path
    assert_equal "You are not authorized to access this area.", flash[:alert]
  end

  test "should show preview on update when preview param is present" do
    sign_in @admin_user
    article = Article.create!(
      title: "Test Preview Article",
      slug: "test-preview-article",
      body: "Content",
      user: @admin_user
    )

    patch admin_article_url(article), params: {
      preview: "1",
      article: {
        title: "Preview Update"
      }
    }

    assert_response :success
    assert_template :preview
  end

  test "owner can destroy any article" do
    sign_in @owner_user
    article_by_admin = Article.create!(
      title: "Admin Article for Owner Destroy",
      slug: "admin-article-owner-destroy",
      body: "Content",
      user: @admin_user
    )

    assert_difference("Article.count", -1) do
      delete admin_article_url(article_by_admin)
    end

    assert_redirected_to admin_articles_url
    assert_equal "Article deleted.", flash[:notice]
  end

  test "admin can destroy their own article" do
    sign_in @admin_user
    article = Article.create!(
      title: "My Article for Destroy",
      slug: "my-article-destroy",
      body: "Content",
      user: @admin_user
    )

    assert_difference("Article.count", -1) do
      delete admin_article_url(article)
    end

    assert_redirected_to admin_articles_url
    assert_equal "Article deleted.", flash[:notice]
  end

  test "admin cannot destroy article created by owner" do
    sign_in @admin_user
    article_by_owner = Article.create!(
      title: "Owner Article Destroy Test",
      slug: "owner-article-destroy-test",
      body: "Content",
      user: @owner_user
    )

    assert_no_difference("Article.count") do
      delete admin_article_url(article_by_owner)
    end
    assert_redirected_to root_path
    assert_equal "You are not authorized to access this area.", flash[:alert]
  end

  test "should find article by slug" do
    sign_in @admin_user
    article_with_slug = Article.create!(
      title: "Slug Test",
      slug: "slug-test",
      body: "Content",
      user: @admin_user
    )

    get admin_article_url(article_with_slug.slug)
    assert_response :success
  end

  test "should handle invalid article creation" do
    sign_in @admin_user
    assert_no_difference("Article.count") do
      post admin_articles_url, params: {
        article: {
          title: ""  # Invalid - title is required
        }
      }
    end

    assert_response :unprocessable_entity
  end
end
