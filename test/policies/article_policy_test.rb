require 'test_helper'

class ArticlePolicyTest < ActiveSupport::TestCase
  setup do
    @owner_user = users(:one)  # permission_id: 1
    @admin_user = users(:three)  # permission_id: 2
    @regular_user = users(:two)  # permission_id: 9
    @article_by_owner = Article.new(title: "Test Article", user: @owner_user)
    @article_by_admin = Article.new(title: "Admin Article", user: @admin_user)
    @article_no_owner = Article.new(title: "Orphan Article", user: nil)
  end

  test "should authorize admin to view index" do
    assert Pundit.policy(@admin_user, Article).index?
    assert Pundit.policy(@owner_user, Article).index?
  end

  test "should not authorize regular user to view index" do
    assert_not Pundit.policy(@regular_user, Article).index?
  end

  test "should not authorize nil user to view index" do
    assert_not Pundit.policy(nil, Article).index?
  end

  test "should authorize admin to show article" do
    assert Pundit.policy(@admin_user, @article_by_owner).show?
    assert Pundit.policy(@owner_user, @article_by_owner).show?
  end

  test "should not authorize regular user to show article" do
    assert_not Pundit.policy(@regular_user, @article_by_owner).show?
  end

  test "should not authorize nil user to show article" do
    assert_not Pundit.policy(nil, @article_by_owner).show?
  end

  test "should authorize admin to create article" do
    assert Pundit.policy(@admin_user, Article.new).create?
    assert Pundit.policy(@owner_user, Article.new).create?
  end

  test "should not authorize regular user to create article" do
    assert_not Pundit.policy(@regular_user, Article.new).create?
  end

  test "should authorize admin to new article" do
    assert Pundit.policy(@admin_user, Article.new).new?
    assert Pundit.policy(@owner_user, Article.new).new?
  end

  test "should not authorize regular user to new article" do
    assert_not Pundit.policy(@regular_user, Article.new).new?
  end

  # Owner authorization tests
  test "owner can update any article" do
    assert Pundit.policy(@owner_user, @article_by_admin).update?
    assert Pundit.policy(@owner_user, @article_by_owner).update?
    assert Pundit.policy(@owner_user, @article_no_owner).update?
  end

  test "owner can destroy any article" do
    assert Pundit.policy(@owner_user, @article_by_admin).destroy?
    assert Pundit.policy(@owner_user, @article_by_owner).destroy?
    assert Pundit.policy(@owner_user, @article_no_owner).destroy?
  end

  # Admin authorization tests - can only edit/delete their own
  test "admin can update their own article" do
    assert Pundit.policy(@admin_user, @article_by_admin).update?
  end

  test "admin cannot update article created by owner" do
    assert_not Pundit.policy(@admin_user, @article_by_owner).update?
  end

  test "admin cannot update article with no owner" do
    assert_not Pundit.policy(@admin_user, @article_no_owner).update?
  end

  test "admin can destroy their own article" do
    assert Pundit.policy(@admin_user, @article_by_admin).destroy?
  end

  test "admin cannot destroy article created by owner" do
    assert_not Pundit.policy(@admin_user, @article_by_owner).destroy?
  end

  test "admin cannot destroy article with no owner" do
    assert_not Pundit.policy(@admin_user, @article_no_owner).destroy?
  end

  # Regular user authorization tests
  test "should not authorize regular user to update article" do
    assert_not Pundit.policy(@regular_user, @article_by_admin).update?
    assert_not Pundit.policy(@regular_user, @article_by_owner).update?
  end

  test "should authorize admin to edit article" do
    assert Pundit.policy(@admin_user, @article_by_admin).edit?
  end

  test "should not authorize regular user to edit article" do
    assert_not Pundit.policy(@regular_user, @article_by_admin).edit?
  end

  test "should not authorize regular user to destroy article" do
    assert_not Pundit.policy(@regular_user, @article_by_admin).destroy?
    assert_not Pundit.policy(@regular_user, @article_by_owner).destroy?
  end

  # Scope tests
  test "owner scope returns all articles" do
    article1 = Article.create!(title: "Article 1", slug: "article-1", body: "Content", user: @owner_user)
    article2 = Article.create!(title: "Article 2", slug: "article-2", body: "Content", user: @admin_user)
    article3 = Article.create!(title: "Article 3", slug: "article-3", body: "Content", user: nil)

    scoped = Pundit.policy_scope(@owner_user, Article)
    assert_includes scoped, article1
    assert_includes scoped, article2
    assert_includes scoped, article3
  end

  test "admin scope returns only their own articles" do
    article1 = Article.create!(title: "Admin Article", slug: "admin-article-scope", body: "Content", user: @admin_user)
    article2 = Article.create!(title: "Owner Article", slug: "owner-article-scope", body: "Content", user: @owner_user)

    scoped = Pundit.policy_scope(@admin_user, Article)
    assert_includes scoped, article1
    assert_not_includes scoped, article2
  end

  test "regular user scope returns no articles" do
    Article.create!(title: "Article", slug: "article-regular-scope", body: "Content", user: @admin_user)

    scoped = Pundit.policy_scope(@regular_user, Article)
    assert_equal 0, scoped.count
  end
end
