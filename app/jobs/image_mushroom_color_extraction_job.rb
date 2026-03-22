# frozen_string_literal: true

class ImageMushroomColorExtractionJob < ApplicationJob
  queue_as :default

  retry_on StandardError, wait: 5.seconds, attempts: 3

  def perform(image_mushroom_id)
    image_mushroom = ImageMushroom.find_by(id: image_mushroom_id)
    return unless image_mushroom&.image_file&.attached?

    result = extract_dominant_color(image_mushroom)
    unless result
      Rails.logger.info("[ImageMushroom##{image_mushroom_id}] dominant color extraction skipped")
      return
    end

    image_mushroom.update_columns(
      dominant_hex: result[:hex],
      dominant_hue: result[:hue],
      color_bucket: result[:bucket],
      updated_at: Time.current
    )
  rescue => e
    Rails.logger.error(
      "[ImageMushroom##{image_mushroom_id}] dominant color extraction failed: #{e.class} - #{e.message}"
    )
    raise
  end

  private

  def extract_dominant_color(image_mushroom)
    if image_mushroom.image_file.variable?
      variant = image_mushroom.image_file.variant(resize_to_limit: [200, 200]).processed
      variant.open(tmpdir: Dir.tmpdir) do |file|
        DominantColorExtractor.extract(file.path)
      end
    else
      image_mushroom.image_file.open(tmpdir: Dir.tmpdir) do |file|
        DominantColorExtractor.extract(file.path)
      end
    end
  end
end
