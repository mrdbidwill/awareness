require "test_helper"

class DominantColorExtractorTest < ActiveSupport::TestCase
  test "rgb_to_hsv returns expected values for red" do
    hue, saturation, value = DominantColorExtractor.rgb_to_hsv(255, 0, 0)
    assert_equal 0, hue
    assert_in_delta 1.0, saturation, 0.01
    assert_in_delta 1.0, value, 0.01
  end

  test "bucket_for maps low saturation and value" do
    assert_equal "black", DominantColorExtractor.bucket_for(0, 0.5, 0.05)
    assert_equal "white", DominantColorExtractor.bucket_for(0, 0.05, 0.95)
    assert_equal "gray", DominantColorExtractor.bucket_for(0, 0.1, 0.5)
  end

  test "extract returns a dominant color payload" do
    file_path = Rails.root.join("test/fixtures/files/test.jpg")

    result = DominantColorExtractor.extract(file_path.to_s)
    assert result.present?
    assert_match(/^#([0-9A-F]{6})$/i, result[:hex])
    assert result[:hue].is_a?(Integer)
    assert result[:bucket].present?
  end
end
