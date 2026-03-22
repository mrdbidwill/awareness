# frozen_string_literal: true

require 'test_helper'

class AuthorizationTest < ActionDispatch::IntegrationTest
  # ============================================================================
  # AUTHORIZATION INTEGRATION TEST
  # ============================================================================
  # This test ensures Pundit authorization works correctly across the application
  # for different user roles and authentication states.
  #
  # Tests three scenarios:
  # 1. Unauthenticated users (guests) - can access public pages only
  # 2. Authenticated non-owners - can view but not edit others' content
  # 3. Authenticated owners - full access to their own content
  # ============================================================================

  setup do
    @owner = users(:one)
    @non_owner = users(:two)
    @mushroom = mushrooms(:one)
    @mushroom.user = @owner
    @mushroom.save!
    @demo_mushroom = mushrooms(:demo)
  end

  # ============================================================================
  # Unauthenticated User Tests (Guests)
  # ============================================================================

  test "unauthenticated users can access public pages without Pundit errors" do
    # Test all public endpoints
    public_endpoints = [
      ['root path', root_path],
      ['mushrooms index', mushrooms_path],
      ['mushroom show', mushroom_path(@demo_mushroom)],
      ['articles index', articles_path]
    ]

    public_endpoints.each do |name, path|
      get path
      assert_response :success, "#{name} should be accessible to guests"
      assert_not_includes response.body, "Internal Server Error",
        "#{name} should not show 500 error"
      assert_not_includes response.body, "Pundit::NotAuthorizedError",
        "#{name} should not raise Pundit error"
    end
  end

  test "unauthenticated users redirected from private pages" do
    private_endpoints = [
      ['mushroom new', new_mushroom_path],
      ['mushroom edit', edit_mushroom_path(@mushroom)],
      ['image new', new_image_mushroom_path(mushroom_id: @mushroom.id)]
    ]

    private_endpoints.each do |name, path|
      get path
      assert_response :redirect, "#{name} should redirect guests"
      assert_redirected_to new_user_session_path,
        "#{name} should redirect to login page"
    end
  end

  test "unauthenticated users cannot create content" do
    # Try to create mushroom
    assert_no_difference('Mushroom.count') do
      post mushrooms_path, params: {
        mushroom: {
          name: 'Unauthorized Mushroom',
          country_id: countries(:one).id,
          fungus_type_id: fungus_types(:one).id,
          collection_date: Date.today
        }
      }
    end
    assert_response :redirect
    assert_redirected_to new_user_session_path
  end

  # ============================================================================
  # Authenticated Non-Owner Tests
  # ============================================================================

  test "authenticated non-owners can view but not edit others' content" do
    sign_in @non_owner

    # Non-owner CAN view owner's mushroom (public show page)
    get mushroom_path(@mushroom)
    assert_response :success, "Non-owners should be able to view public mushroom pages"

    # Non-owner CANNOT edit owner's mushroom
    get edit_mushroom_path(@mushroom)
    assert_response :redirect, "Non-owners should not be able to edit others' mushrooms"

    # Non-owner CANNOT update owner's mushroom
    assert_no_changes -> { @mushroom.reload.name } do
      patch mushroom_path(@mushroom), params: {
        mushroom: { name: 'Hacked Name' }
      }
    end
    # Mushroom name should not have changed
    assert_response :redirect
  end

  test "authenticated non-owners cannot delete others' content" do
    sign_in @non_owner

    # Non-owner CANNOT delete owner's mushroom
    assert_no_difference('Mushroom.count') do
      delete mushroom_path(@mushroom)
    end

    assert_response :redirect
  end

  test "authenticated non-admin users cannot access admin area" do
    sign_in @non_owner

    # Regular users should not access admin routes
    get admin_root_path
    assert_response :redirect
    assert_redirected_to root_path
  end

  # ============================================================================
  # Authenticated Owner Tests
  # ============================================================================

  test "authenticated owners have full access to their own content" do
    sign_in @owner

    # Owner CAN view their own mushroom
    get mushroom_path(@mushroom)
    assert_response :success

    # Owner CAN edit their own mushroom
    get edit_mushroom_path(@mushroom)
    assert_response :success

    # Owner CAN update their own mushroom
    patch mushroom_path(@mushroom), params: {
      mushroom: { name: 'Updated Name' }
    }
    assert_redirected_to mushroom_path(@mushroom)
    @mushroom.reload
    assert_equal 'Updated Name', @mushroom.name

    # Owner CAN delete their own mushroom
    assert_difference('Mushroom.count', -1) do
      delete mushroom_path(@mushroom)
    end
    assert_redirected_to mushrooms_path
  end

  test "authenticated owners can create new content" do
    sign_in @owner

    # Owner CAN create new mushrooms
    assert_difference('Mushroom.count', 1) do
      post mushrooms_path, params: {
        mushroom: {
          name: 'New Mushroom',
          country_id: countries(:one).id,
          fungus_type_id: fungus_types(:one).id,
          collection_date: Date.today
        }
      }
    end
    assert_redirected_to new_image_mushroom_path(mushroom_id: Mushroom.last.id)
  end

  # ============================================================================
  # Admin User Tests
  # ============================================================================

  test "admin users have access to admin area" do
    # Make owner an admin
    @owner.update!(permission_id: 2) # 2 = admin
    sign_in @owner

    get admin_root_path
    assert_response :success
  end

  test "admin users can access others' content" do
    # Make non_owner an admin
    @non_owner.update!(permission_id: 2)
    @non_owner.reload
    assert @non_owner.admin?, "User should be admin"

    sign_in @non_owner

    # Admin CAN edit others' mushrooms
    get edit_mushroom_path(@mushroom)
    assert_response :success, "Admins should be able to edit others' mushrooms"

    # Admin CAN update others' mushrooms
    patch mushroom_path(@mushroom), params: {
      mushroom: { name: 'Admin Updated' }
    }
    assert_redirected_to mushroom_path(@mushroom)
    @mushroom.reload
    assert_equal 'Admin Updated', @mushroom.name

    # Admin CAN delete others' mushrooms
    other_mushroom = Mushroom.create!(
      name: 'Test Mushroom for Deletion',
      user: @owner,
      country: countries(:one),
      fungus_type: fungus_types(:one),
      collection_date: Date.today
    )
    assert_difference('Mushroom.count', -1) do
      delete mushroom_path(other_mushroom)
    end
    assert_redirected_to mushrooms_path

    # Admin CAN manage others' images (test policy coverage)
    test_mushroom = Mushroom.create!(
      name: 'Test Mushroom for Images',
      user: @owner,
      country: countries(:one),
      fungus_type: fungus_types(:one),
      collection_date: Date.today
    )

    # Create an image owned by another user
    part = Part.first || Part.create!(name: 'Test Part', description: 'Test')
    image = test_mushroom.image_mushrooms.create!(
      part_id: part.id,
      image_file: fixture_file_upload('test_image.jpg', 'image/jpeg')
    )

    # Admin can view the image
    get image_mushroom_path(image)
    assert_response :success, "Admins should be able to view others' images"

    # Admin can edit the image
    get edit_image_mushroom_path(image)
    assert_response :success, "Admins should be able to edit others' images"

    # Admin can update the image
    patch image_mushroom_path(image), params: {
      image_mushroom: { comments: 'Admin updated comments' }
    }
    assert_redirected_to edit_mushroom_path(test_mushroom)
    image.reload
    assert_equal 'Admin updated comments', image.comments

    # Admin can delete the image
    assert_difference('ImageMushroom.count', -1) do
      delete image_mushroom_path(image)
    end
  end

  # ============================================================================
  # Pundit Callback Tests
  # ============================================================================

  test "verify_authorized callback works for authenticated users" do
    sign_in @owner

    # This should work without Pundit errors
    get mushroom_path(@mushroom)
    assert_response :success

    # No Pundit::AuthorizationNotPerformedError should be raised
  end

  test "verify_policy_scoped callback works for index actions" do
    sign_in @owner

    # Index action uses policy_scope
    get mushrooms_path
    assert_response :success

    # No Pundit error should be raised
  end

  test "skip_after_action works when not authenticated" do
    # This is the critical test that would have caught our production bug
    # When not authenticated, controllers should skip Pundit verification

    # These should work without raising Pundit callback errors
    get mushrooms_path  # Uses skip_after_action :verify_policy_scoped
    assert_response :success

    get mushroom_path(@demo_mushroom)  # Public demo show should pass authorization
    assert_response :success

    # If we got here without errors, skip_after_action is working correctly
  end
end
