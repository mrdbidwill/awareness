# frozen_string_literal: true

require "vips"

class DominantColorExtractor
  QUANTIZATION_STEP = 16

  def self.extract(file_path)
    image = Vips::Image.new_from_file(file_path, access: :sequential)
    image = image.colourspace("srgb")
    image = image.extract_band(0, n: 3) if image.bands > 3
    image = image.thumbnail_image(64, height: 64, size: :down)

    counts = Hash.new(0)
    image.to_a.each do |row|
      row.each do |pixel|
        r, g, b = pixel
        next unless r && g && b

        key = ((r / QUANTIZATION_STEP).to_i << 8) |
              ((g / QUANTIZATION_STEP).to_i << 4) |
              (b / QUANTIZATION_STEP).to_i
        counts[key] += 1
      end
    end

    return nil if counts.empty?

    dominant_key = counts.max_by { |_, count| count }[0]
    r_bin = (dominant_key >> 8) & 0xF
    g_bin = (dominant_key >> 4) & 0xF
    b_bin = dominant_key & 0xF

    r = r_bin * QUANTIZATION_STEP + (QUANTIZATION_STEP / 2)
    g = g_bin * QUANTIZATION_STEP + (QUANTIZATION_STEP / 2)
    b = b_bin * QUANTIZATION_STEP + (QUANTIZATION_STEP / 2)

    hue, saturation, value = rgb_to_hsv(r, g, b)

    {
      hex: format("#%02X%02X%02X", r, g, b),
      hue: hue,
      bucket: bucket_for(hue, saturation, value)
    }
  end

  def self.rgb_to_hsv(r, g, b)
    r_f = r / 255.0
    g_f = g / 255.0
    b_f = b / 255.0

    max = [r_f, g_f, b_f].max
    min = [r_f, g_f, b_f].min
    delta = max - min

    hue =
      if delta.zero?
        0.0
      elsif max == r_f
        60 * (((g_f - b_f) / delta) % 6)
      elsif max == g_f
        60 * (((b_f - r_f) / delta) + 2)
      else
        60 * (((r_f - g_f) / delta) + 4)
      end

    saturation = max.zero? ? 0.0 : delta / max
    value = max

    [hue.round % 360, saturation, value]
  end

  def self.bucket_for(hue, saturation, value)
    return "black" if value < 0.12
    return "white" if saturation < 0.12 && value > 0.9
    return "gray" if saturation < 0.18

    case hue
    when 0..14, 345..359
      "red"
    when 15..44
      "orange"
    when 45..69
      "yellow"
    when 70..159
      "green"
    when 160..199
      "teal"
    when 200..249
      "blue"
    when 250..289
      "purple"
    when 290..344
      "magenta"
    else
      "unknown"
    end
  end
end
