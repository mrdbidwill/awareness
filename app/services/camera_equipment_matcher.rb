# Service to match EXIF strings to database records for camera equipment
# Handles fuzzy matching with normalization for camera makes, models, and lenses
class CameraEquipmentMatcher
  # Match camera make from EXIF string (e.g., "NIKON CORPORATION" -> Nikon)
  def self.match_camera_make(exif_make_string)
    return nil if exif_make_string.blank?

    normalized = normalize_string(exif_make_string)

    # Try exact match first
    match = CameraMake.find_by("LOWER(REPLACE(name, ' ', '')) = ?", normalized)
    return match if match

    # Try partial match (e.g., "NIKON CORPORATION" contains "nikon")
    CameraMake.find do |make|
      make_normalized = normalize_string(make.name)
      normalized.include?(make_normalized) || make_normalized.include?(normalized)
    end
  end

  # Match camera model from EXIF string (e.g., "NIKON Z 6_2" -> Z6 II)
  def self.match_camera_model(exif_model_string)
    return nil if exif_model_string.blank?

    normalized = normalize_string(exif_model_string)

    # Try exact normalized match first
    match = CameraModel.find_by("LOWER(REPLACE(name, ' ', '')) = ?", normalized)
    return match if match

    # Try partial match (useful for "Canon EOS 5D Mark IV" -> "EOS 5D Mark IV")
    CameraModel.find do |model|
      model_normalized = normalize_string(model.name)
      normalized.include?(model_normalized) || model_normalized.include?(normalized)
    end
  end

  # Match lens from EXIF string
  # Lenses are more specific, so we do stricter matching
  def self.match_lens(exif_lens_string)
    return nil if exif_lens_string.blank?

    # Try exact match first (case insensitive)
    match = Lens.find do |lens|
      full_name = "#{lens.make} #{lens.model}"
      normalize_string(full_name) == normalize_string(exif_lens_string)
    end
    return match if match

    # Try partial match on model only (in case make is different/missing)
    Lens.find do |lens|
      model_normalized = normalize_string(lens.model)
      exif_normalized = normalize_string(exif_lens_string)
      exif_normalized.include?(model_normalized)
    end
  end

  private

  # Normalize string for matching: lowercase, remove spaces and special chars
  def self.normalize_string(str)
    return "" if str.blank?

    str.to_s
       .downcase
       .gsub(/[^a-z0-9]/, "") # Remove all non-alphanumeric
  end
end
