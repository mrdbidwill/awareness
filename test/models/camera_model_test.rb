# test/models/camera_model_test.rb
require "test_helper"

class CameraModelTest < ActiveSupport::TestCase
  def setup
    @camera_model = camera_models(:one)
  end

  test "should be valid with valid attributes" do
    assert @camera_model.valid?
  end

  test "should require name" do
    camera_model = CameraModel.new
    assert_not camera_model.valid?
    assert_includes camera_model.errors[:name], "Name cannot be blank."
  end

  test "should have many cameras" do
    assert_respond_to @camera_model, :cameras
  end

  test "should nullify cameras when destroyed" do
    camera_model = CameraModel.create!(name: "Test Model")
    camera_make = camera_makes(:one)
    camera = Camera.create!(name: "Test Camera", camera_make: camera_make, camera_model: camera_model)

    camera_model.destroy
    assert_nil camera.reload.camera_model_id
  end

  test "should have timestamps" do
    assert_not_nil @camera_model.created_at
    assert_not_nil @camera_model.updated_at
  end
end
