require "test_helper"

class ImageMushroomsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @mushroom = mushrooms(:one)
    @mushroom.user = @user
    @mushroom.save!
    @image_mushroom = image_mushrooms(:one)
    @image_mushroom.mushroom = @mushroom
    @demo_mushroom = mushrooms(:demo)
    @demo_image = image_mushrooms(:demo)
    # Attach test image file to satisfy validation
    @image_mushroom.image_file.attach(
      io: File.open(Rails.root.join('test', 'files', 'test_image.jpg')),
      filename: 'test_image.jpg',
      content_type: 'image/jpeg'
    )
    @image_mushroom.save!
    @demo_image.mushroom = @demo_mushroom
    @demo_image.image_file.attach(
      io: File.open(Rails.root.join('test', 'files', 'test_image.jpg')),
      filename: 'demo_image.jpg',
      content_type: 'image/jpeg'
    )
    @demo_image.save!
  end

  # ============================================================================
  # Public Access Tests (Pundit Authorization)
  # ============================================================================
  # These tests ensure public pages don't raise Pundit errors

  test "should get index without authentication" do
    get image_mushrooms_url
    assert_response :success
    assert_not_includes response.body, "Internal Server Error"
  end

  test "should show image without authentication" do
    get image_mushroom_url(@demo_image)
    assert_response :success
    assert_not_includes response.body, "Internal Server Error"
  end

  test "should not show non-demo image without authentication" do
    get image_mushroom_url(@image_mushroom)
    assert_response :redirect
  end

  test "authenticated user should get new" do
    sign_in @user
    get new_image_mushroom_url(mushroom_id: @mushroom.id)
    assert_response :success
  end

  test "should require mushroom_id for new" do
    sign_in @user
    get new_image_mushroom_url
    assert_redirected_to mushrooms_path
    assert_match /choose a mushroom/, flash[:alert]
  end

  test "should create image_mushroom" do
    sign_in @user

    assert_difference("ImageMushroom.count") do
      post image_mushrooms_url, params: {
        mushroom_id: @mushroom.id,
        image_mushroom: {
          mushroom_id: @mushroom.id,
          part_id: @image_mushroom.part_id,
          image_name: "Test Image",
          image_file: fixture_file_upload('test_image.jpg', 'image/jpeg')
        }
      }
    end

    assert_redirected_to mushroom_path(@mushroom)
    assert_equal "Image successfully uploaded.", flash[:notice]
  end

  test "should require mushroom_id for create" do
    sign_in @user

    post image_mushrooms_url, params: {
      image_mushroom: {
        part_id: @image_mushroom.part_id,
        image_name: "Test"
      }
    }

    assert_redirected_to mushrooms_path
    assert_match /choose a mushroom/, flash[:alert]
  end

  test "should get edit" do
    sign_in @user
    get edit_image_mushroom_url(@image_mushroom)
    assert_response :success
  end

  test "should update image_mushroom" do
    sign_in @user

    patch image_mushroom_url(@image_mushroom), params: {
      image_mushroom: {
        image_name: "Updated Image"
      }
    }

    assert_redirected_to edit_mushroom_path(@mushroom)
    assert_equal "Image was successfully updated.", flash[:notice]
  end

  test "should destroy image_mushroom" do
    sign_in @user

    assert_difference("ImageMushroom.count", -1) do
      delete image_mushroom_url(@image_mushroom)
    end

    assert_redirected_to mushroom_path(@mushroom)
    assert_equal "Image was successfully deleted.", flash[:notice]
  end

  test "should destroy image_mushroom and redirect" do
    sign_in @user

    assert_difference("ImageMushroom.count", -1) do
      delete image_mushroom_url(@image_mushroom)
    end

    assert_redirected_to mushroom_path(@mushroom)
    assert_equal "Image was successfully deleted.", flash[:notice]
  end

  test "guest should not create image" do
    post image_mushrooms_url, params: {
      mushroom_id: @mushroom.id,
      image_mushroom: {
        mushroom_id: @mushroom.id,
        part_id: @image_mushroom.part_id,
        image_file: fixture_file_upload('test_image.jpg', 'image/jpeg')
      }
    }

    assert_redirected_to new_user_session_path
  end

  test "should handle invalid update" do
    sign_in @user

    patch image_mushroom_url(@image_mushroom), params: {
      image_mushroom: {
        mushroom_id: nil  # Invalid
      }
    }

    assert_response :unprocessable_entity
  end
end
