require "test_helper"

class Admin::ImageMushroomsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @camera_make = camera_makes(:one)
    @camera_model = camera_models(:one)
    @image_mushroom = image_mushrooms(:one)
    @mushroom = mushrooms(:one)

    # Ensure existing fixture record has an attached image to satisfy validations
    unless @image_mushroom.image_file.attached?
      image_file = fixture_file_upload("test_image.jpg", "image/jpeg")
      @image_mushroom.image_file.attach(image_file)
    end

    @image_mushroom.update!(mushroom: @mushroom, camera_make: @camera_make, camera_model: @camera_model)

    # Sign in user for authentication
    @user = users(:one)
    @user.permission_id = 2
    sign_in @user
  end

  test "should get index" do
    get admin_image_mushrooms_path
    assert_response :success
  end

  test "should get new" do
    get new_admin_image_mushroom_path(mushroom_id: @mushroom.id)
    assert_response :success
  end

  test "should create image mushroom with valid data" do
    # Create a new mushroom for user:one to avoid duplicate file validation
    country = countries(:one)
    fungus_type = fungus_types(:one)
    other_mushroom = Mushroom.create!(
      user: @user,
      name: "Test Mushroom #{Time.now.to_i}",
      description: "Test",
      country: country,
      fungus_type: fungus_type,
      collection_date: Date.today
    )
    image_file = fixture_file_upload("test_image.jpg", "image/jpeg")

    assert_difference("ImageMushroom.count") do
      post admin_image_mushrooms_url, params: {
        image_mushroom: {
          image_name: "Test Image",
          mushroom_id: other_mushroom.id,
          part_id: parts(:one).id,
          camera_make_id: @camera_make.id,
          camera_model_id: @camera_model.id,
          image_file: image_file,
          exposure: "1/60",
          aperture: "f/2.8",
          iso: "100"
        }
      }
    end
    assert_redirected_to admin_image_mushroom_path(ImageMushroom.last)
  end

  test "should show image_mushroom" do
    get admin_image_mushroom_path(@image_mushroom)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_image_mushroom_path(@image_mushroom)
    assert_response :success
  end

  test "should update image mushroom" do
    patch admin_image_mushroom_path(@image_mushroom), params: {
      image_mushroom: {
        image_name: "Updated Picture"
      }
    }
    assert_redirected_to admin_image_mushroom_path(@image_mushroom)
  end


  test "should destroy image_mushroom" do
    assert_difference("ImageMushroom.count", -1) do
      delete admin_image_mushroom_path(@image_mushroom)
    end

    assert_redirected_to admin_image_mushrooms_path
  end
end


