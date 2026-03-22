# test/models/camera_test.rb
require "test_helper"

class CameraTest < ActiveSupport::TestCase
  def setup
    @camera_make = camera_makes(:one)
    @camera_model = camera_models(:one)
    @camera = cameras(:one)
  end

  test "should be valid with valid attributes" do
    assert @camera.valid?
  end

  test "should require name" do
    camera = Camera.new(camera_make: @camera_make, camera_model: @camera_model)
    assert_not camera.valid?
    assert_includes camera.errors[:name], "Name cannot be blank."
  end

  test "should belong to camera_make" do
    assert_respond_to @camera, :camera_make
    assert_instance_of CameraMake, @camera.camera_make
  end

  test "should belong to camera_model" do
    assert_respond_to @camera, :camera_model
    assert_instance_of CameraModel, @camera.camera_model
  end

  test "should have timestamps" do
    assert_not_nil @camera.created_at
    assert_not_nil @camera.updated_at
  end
end
