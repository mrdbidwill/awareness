# test/models/camera_make_test.rb
require "test_helper"

class CameraMakeTest < ActiveSupport::TestCase
  def setup
    @camera_make = camera_makes(:one)
  end

  test "should be valid with valid attributes" do
    assert @camera_make.valid?
  end

  test "should require name" do
    camera_make = CameraMake.new
    assert_not camera_make.valid?
    assert_includes camera_make.errors[:name], "Name cannot be blank."
  end

  test "should require unique name" do
    CameraMake.create!(name: "UniqueCamera")
    duplicate = CameraMake.new(name: "UniqueCamera")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:name], "has already been taken"
  end

  test "should have many cameras" do
    assert_respond_to @camera_make, :cameras
  end

  test "should nullify cameras when destroyed" do
    camera_make = CameraMake.create!(name: "Test Make")
    camera_model = camera_models(:one)
    camera = Camera.create!(name: "Test Camera", camera_make: camera_make, camera_model: camera_model)

    camera_make.destroy
    assert_nil camera.reload.camera_make_id
  end

  test "should have timestamps" do
    assert_not_nil @camera_make.created_at
    assert_not_nil @camera_make.updated_at
  end
end
