require "test_helper"

class Admin::SourcesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @owner_user = users(:one)
    @regular_user = users(:two)
    @source = sources(:one)
  end

  test "admin can list sources" do
    sign_in @owner_user
    get admin_sources_url
    assert_response :success
    assert_includes response.body, @source.name
  end

  test "admin list is ordered alphabetically while ignoring leading articles" do
    sign_in @owner_user
    Source.create!(name: "The Zebra Manual")
    Source.create!(name: "An Apple Study")
    Source.create!(name: "Mushroom Compendium")

    get admin_sources_url
    assert_response :success

    body = response.body
    apple_index = body.index("An Apple Study")
    mushroom_index = body.index("Mushroom Compendium")
    zebra_index = body.index("The Zebra Manual")

    assert apple_index.present?
    assert mushroom_index.present?
    assert zebra_index.present?
    assert_operator apple_index, :<, mushroom_index
    assert_operator mushroom_index, :<, zebra_index
  end

  test "admin can search sources" do
    sign_in @owner_user
    matching = Source.create!(name: "Unique Search Source")
    Source.create!(name: "Completely Different Name")

    get admin_sources_url, params: { q: "Unique Search Source" }
    assert_response :success
    assert_includes response.body, matching.name
    assert_includes response.body, "value=\"Unique Search Source\""
    refute_includes response.body, "Completely Different Name"
  end

  test "admin can create source" do
    sign_in @owner_user

    assert_difference("Source.count", 1) do
      post admin_sources_url, params: {
        source: {
          name: "New Source",
          author: "Editor",
          description: "Useful background text.",
          publish_year: "2026"
        }
      }
    end

    assert_redirected_to admin_source_url(Source.last)
    assert_equal Date.new(2026, 1, 1), Source.last.publish_date
  end

  test "admin can create source with long author and description" do
    sign_in @owner_user

    long_author = "Author Name; " * 50
    long_description = "Abstract paragraph. " * 4500

    assert_difference("Source.count", 1) do
      post admin_sources_url, params: {
        source: {
          name: "Long Metadata Source",
          author: long_author,
          description: long_description,
          publish_year: "2025"
        }
      }
    end

    created = Source.order(:id).last
    assert_redirected_to admin_source_url(created)
    assert_equal long_author, created.author
    assert_equal long_description, created.description
    assert_equal Date.new(2025, 1, 1), created.publish_date
  end

  test "admin can update source" do
    sign_in @owner_user

    patch admin_source_url(@source), params: {
      source: { name: "Updated Source Name" }
    }

    assert_redirected_to admin_source_url(@source)
    assert_equal "Updated Source Name", @source.reload.name
  end

  test "admin can destroy source" do
    sign_in @owner_user

    assert_difference("Source.count", -1) do
      delete admin_source_url(@source)
    end

    assert_redirected_to admin_sources_url
  end

  test "non-admin cannot access sources" do
    sign_in @regular_user
    get admin_sources_url

    assert_redirected_to root_path
    assert_equal "You are not authorized to access this area.", flash[:alert]
  end
end
