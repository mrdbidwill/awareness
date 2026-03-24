require "test_helper"

class ArticleSourceCitationTest < ActiveSupport::TestCase
  test "fixture citation is valid" do
    citation = article_source_citations(:one)
    assert citation.valid?
    assert_equal "p. 42", citation.page_locator
  end

  test "requires article and source" do
    citation = ArticleSourceCitation.new(page_locator: "p. 10")

    assert_not citation.valid?
    assert citation.errors[:article].any?
    assert citation.errors[:source].any?
  end
end
