# frozen_string_literal: true

require "test_helper"

class ImageMushroomColorExtractionJobTest < ActiveJob::TestCase
  test "updates dominant color fields when extractor returns data" do
    mushroom = mushrooms(:one)
    image_mushroom = ImageMushroom.new(mushroom: mushroom, image_name: "Color Test")
    image_mushroom.image_file.attach(
      io: File.open(Rails.root.join("test/fixtures/files/test.jpg")),
      filename: "test.jpg",
      content_type: "image/jpeg"
    )
    image_mushroom.save!

    job = ImageMushroomColorExtractionJob.new
    job.define_singleton_method(:extract_dominant_color) do |_record|
      { hex: "#ABCDEF", hue: 200, bucket: "blue" }
    end
    job.perform(image_mushroom.id)

    image_mushroom.reload
    assert_equal "#ABCDEF", image_mushroom.dominant_hex
    assert_equal 200, image_mushroom.dominant_hue
    assert_equal "blue", image_mushroom.color_bucket
  end
end
