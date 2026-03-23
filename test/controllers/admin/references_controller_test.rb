require "test_helper"

class Admin::ReferencesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @owner_user = users(:one)
    @regular_user = users(:two)
    @reference = references(:one)
  end

  test "admin can list references" do
    sign_in @owner_user
    get admin_references_url
    assert_response :success
    assert_includes response.body, @reference.name
  end

  test "admin can create reference" do
    sign_in @owner_user

    assert_difference("Reference.count", 1) do
      post admin_references_url, params: {
        reference: {
          name: "New Reference",
          author: "Editor",
          description: "Useful background text.",
          publish_date: "2026-01-01"
        }
      }
    end

    assert_redirected_to admin_reference_url(Reference.last)
  end

  test "admin can update reference" do
    sign_in @owner_user

    patch admin_reference_url(@reference), params: {
      reference: { name: "Updated Reference Name" }
    }

    assert_redirected_to admin_reference_url(@reference)
    assert_equal "Updated Reference Name", @reference.reload.name
  end

  test "admin can destroy reference" do
    sign_in @owner_user

    assert_difference("Reference.count", -1) do
      delete admin_reference_url(@reference)
    end

    assert_redirected_to admin_references_url
  end

  test "non-admin cannot access references" do
    sign_in @regular_user
    get admin_references_url

    assert_redirected_to root_path
    assert_equal "You are not authorized to access this area.", flash[:alert]
  end
end
