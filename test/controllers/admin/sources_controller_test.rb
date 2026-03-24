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
