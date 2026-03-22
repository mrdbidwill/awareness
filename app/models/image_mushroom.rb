class ImageMushroom < ApplicationRecord
  belongs_to :mushroom
  belongs_to :part, optional: true
  belongs_to :camera_make, optional: true
  belongs_to :camera_model, optional: true
  belongs_to :lens, optional: true

  # Attachments and presence validations
  has_one_attached :image_file

  ALLOWED_CONTENT_TYPES = %w[
    image/jpeg
    image/png
    image/heic
    image/heif
    image/webp
    image/tiff
    image/gif
  ].freeze
  MAX_IMAGE_BYTES = 25.megabytes

  validates :image_file, presence: { message: "An image file must be selected" }
  validate :unique_file_per_mushroom
  validate :image_file_content_type
  validate :image_file_size

  # Ensure the Mushroom is associated with the correct user if needed
  def user_id
    mushroom.user_id
  end

  # Convenience for views/tests
  def dimensions
    if image_width.present? && image_height.present?
      "#{image_width}x#{image_height}"
    else
      nil
    end
  end

  # Extract EXIF after create and when image_file changes
  after_commit :extract_exif_if_needed, on: [:create, :update]
  after_commit :preprocess_thumbnail_variant, on: [:create, :update]
  after_commit :sync_storage_metadata, on: [:create, :update]
  after_commit :enqueue_color_extraction, on: [:create, :update]

  private

  def unique_file_per_mushroom
    return unless image_file.attached?

    # Get the blob checksum for the attached file
    blob_checksum = image_file.blob.checksum

    # Check if another image_mushroom for this mushroom has the same blob
    duplicate = ImageMushroom
      .joins(image_file_attachment: :blob)
      .where(mushroom_id: mushroom_id)
      .where.not(id: id) # Exclude self when editing
      .where(active_storage_blobs: { checksum: blob_checksum })
      .exists?

    if duplicate
      errors.add(:image_file, "has already been uploaded for this mushroom")
    end
  end

  def image_file_content_type
    return unless image_file.attached?
    return if ALLOWED_CONTENT_TYPES.include?(image_file.blob.content_type)

    extension = image_file.filename.extension&.downcase
    return if %w[heic heif].include?(extension)

    errors.add(:image_file, "must be a supported image type")
  end

  def image_file_size
    return unless image_file.attached?
    return if image_file.blob.byte_size <= MAX_IMAGE_BYTES

    errors.add(:image_file, "must be smaller than #{MAX_IMAGE_BYTES / 1.megabyte}MB")
  end

  def extract_exif_if_needed
    return unless image_file.attached?
    # Only run if this record was just created or the image changed
    if previous_changes.key?("id") || attachment_changed?
      extract_and_store_exif
    end
  end

  def attachment_changed?
    # Detect attachment changes across Rails versions
    if respond_to?(:saved_change_to_image_file_attachment?)
      saved_change_to_image_file_attachment?
    else
      image_file.attachment&.previous_changes&.key?("blob_id")
    end
  end

  def extract_and_store_exif
    # Prefer EXIFR for JPEG/TIFF, fall back to ExifTool for HEIC/RAW/others
    image_file.open(tmpdir: Dir.tmpdir) do |file|
      data = exif_from_exifr(file) || exif_from_exiftool(file)
      return unless data

      # Only fill blanks to preserve any manual overrides
      self.image_width  ||= data[:image_width]
      self.image_height ||= data[:image_height]
      self.exif_make    ||= data[:camera_make]
      self.exif_model   ||= data[:camera_model]
      self.exif_lens    ||= data[:lens]
      self.exposure     ||= data[:exposure]
      self.aperture     ||= data[:aperture]
      self.iso          ||= data[:iso]
      self.date_taken   ||= data[:date_taken]
      self.latitude     ||= data[:latitude]
      self.longitude    ||= data[:longitude]

      # Auto-match EXIF strings to database records (only if foreign keys not set)
      if camera_make_id.nil? && data[:camera_make].present?
        matched_make = CameraEquipmentMatcher.match_camera_make(data[:camera_make])
        self.camera_make_id = matched_make.id if matched_make
      end

      if camera_model_id.nil? && data[:camera_model].present?
        matched_model = CameraEquipmentMatcher.match_camera_model(data[:camera_model])
        self.camera_model_id = matched_model.id if matched_model
      end

      if lens_id.nil? && data[:lens].present?
        matched_lens = CameraEquipmentMatcher.match_lens(data[:lens])
        self.lens_id = matched_lens.id if matched_lens
      end

      save(validate: false)
    end
  rescue => e
    Rails.logger.info("[ImageMushroom##{id}] EXIF extraction skipped: #{e.class} - #{e.message}")
  end

  def sync_storage_metadata
    return unless image_file.attached?
    return unless attachment_changed? || previous_changes.key?("id")

    blob = image_file.blob
    updates = {}
    updates[:image_storage_key] = blob.key if image_storage_key != blob.key
    updates[:image_content_type] = blob.content_type if image_content_type != blob.content_type
    updates[:image_byte_size] = blob.byte_size if image_byte_size != blob.byte_size

    public_url = public_image_url
    updates[:image_public_url] = public_url if image_public_url != public_url

    return if updates.empty?

    updates[:updated_at] = Time.current
    update_columns(updates)

    Rails.logger.info(
      "[ImageMushroom##{id}] upload_complete key=#{blob.key} size=#{blob.byte_size} content_type=#{blob.content_type}"
    )
  end

  def enqueue_color_extraction
    return unless image_file.attached?
    return unless attachment_changed? || previous_changes.key?("id")

    ImageMushroomColorExtractionJob.perform_later(id)
  end

  def public_image_url
    base = Rails.application.config.x.r2_public_base_url.to_s.strip
    return nil if base.empty?

    "#{base.chomp("/")}/#{image_file.blob.key}"
  end

  def exif_from_exifr(file)
    require "exifr/jpeg"
    require "exifr/tiff"
    exif = nil
    begin
      exif = EXIFR::JPEG.new(file)
      exif = nil unless exif&.exif?
    rescue StandardError
      exif = nil
    end

    if exif.nil?
      begin
        exif = EXIFR::TIFF.new(file)
      rescue StandardError
        exif = nil
      end
    end

    return nil unless exif

    lat = nil
    lon = nil
    if exif.respond_to?(:gps_latitude) && exif.gps_latitude
      lat_array = exif.gps_latitude
      lat_ref = exif.respond_to?(:gps_latitude_ref) ? exif.gps_latitude_ref : nil
      lat = convert_gps_array_to_decimal(lat_array, lat_ref)
    end
    if exif.respond_to?(:gps_longitude) && exif.gps_longitude
      lon_array = exif.gps_longitude
      lon_ref = exif.respond_to?(:gps_longitude_ref) ? exif.gps_longitude_ref : nil
      lon = convert_gps_array_to_decimal(lon_array, lon_ref)
    end

    {
      image_width:  safe_int(exif.width),
      image_height: safe_int(exif.height),
      camera_make:  exif.make.to_s.presence,
      camera_model: exif.model.to_s.presence,
      lens:         (exif.respond_to?(:lens_model) ? exif.lens_model.to_s.presence : nil),
      exposure:     format_exposure(exif.respond_to?(:exposure_time) ? exif.exposure_time : nil),
      aperture:     format_aperture(exif.respond_to?(:f_number) ? exif.f_number : nil),
      iso:          (exif.respond_to?(:iso_speed_ratings) ? Array(exif.iso_speed_ratings).compact.first.to_s.presence : nil),
      date_taken:   (exif.respond_to?(:date_time_original) ? parse_exif_datetime(exif.date_time_original) : nil),
      latitude:     lat,
      longitude:    lon
    }
  rescue => e
    Rails.logger.debug("[ImageMushroom##{id}] EXIFR parse failed: #{e.class} - #{e.message}")
    nil
  end

  def exif_from_exiftool(file)
    require "mini_exiftool"
    tags = MiniExiftool.new(file.path)

    width  = (tags[:image_width]  || tags[:exif_image_width]  || nil)
    height = (tags[:image_height] || tags[:exif_image_height] || nil)

    exp = tags[:exposure_time] # Often like "1/125"
    # If exposure is numeric (rare), format similarly
    exposure_str =
      if exp.is_a?(String)
        exp.end_with?("s") ? exp : "#{exp}s"
      elsif exp.respond_to?(:to_f)
        format_exposure(exp.to_f)
      else
        nil
      end

    fnum = tags[:fnumber] || tags[:f_number]
    aperture_str = fnum ? format_aperture(fnum) : nil

    date_original = tags[:date_time_original] || tags[:datetimeoriginal] || tags[:create_date]

    {
      image_width:  safe_int(width),
      image_height: safe_int(height),
      camera_make:  tags[:make].to_s.presence,
      camera_model: tags[:model].to_s.presence,
      lens:         (tags[:lens_model] || tags[:lens] || nil).to_s.presence,
      exposure:     exposure_str,
      aperture:     aperture_str,
      iso:          (tags[:iso] || tags[:iso_speed_ratings]).to_s.presence,
      date_taken:   parse_exif_datetime(date_original),
      latitude:     parse_gps_coordinate(tags[:gps_latitude] || tags[:gpslatitude]),
      longitude:    parse_gps_coordinate(tags[:gps_longitude] || tags[:gpslongitude])
    }
  rescue => e
    Rails.logger.debug("[ImageMushroom##{id}] ExifTool parse failed: #{e.class} - #{e.message}")
    nil
  end

  def safe_int(value)
    Integer(value) rescue nil
  end

  def format_exposure(exp)
    return nil unless exp
    # EXIFR can give Rational or Numeric
    rational = exp.respond_to?(:numerator) ? exp : nil
    seconds =
      if rational
        num = rational.numerator.to_f
        den = rational.denominator.to_f
        return nil if num.zero? || den.zero?
        num / den
      else
        exp.to_f
      end
    return nil if seconds <= 0
    if seconds < 1.0
      denom = (1.0 / seconds).round
      "1/#{denom}s"
    else
      "#{seconds.round(2)}s"
    end
  end

  def format_aperture(fnum)
    return nil unless fnum
    f = fnum.to_f
    return nil if f <= 0
    "f/#{f.round(1)}"
  end

  def parse_exif_datetime(value)
    return nil if value.nil?

    # If already a Time/DateTime object, convert to datetime
    return value.to_datetime if value.respond_to?(:to_datetime)

    # If it's a string, try parsing common EXIF formats
    return nil unless value.is_a?(String)

    # EXIF format: "YYYY:MM:DD HH:MM:SS"
    if value =~ /^(\d{4}):(\d{2}):(\d{2})\s+(\d{2}):(\d{2}):(\d{2})/
      DateTime.strptime(value, "%Y:%m:%d %H:%M:%S") rescue nil
    else
      # Try ISO8601 or other standard formats
      DateTime.parse(value) rescue nil
    end
  end

  def convert_gps_array_to_decimal(gps_array, ref)
    return nil unless gps_array.is_a?(Array) && gps_array.length >= 2

    # EXIFR returns [degrees, minutes, seconds] as Rational numbers
    degrees = gps_array[0].to_f
    minutes = gps_array[1].to_f
    seconds = gps_array[2]&.to_f || 0.0

    # Convert to decimal degrees
    decimal = degrees + (minutes / 60.0) + (seconds / 3600.0)

    # Apply negative sign for South and West
    decimal = -decimal if ref&.to_s&.upcase&.start_with?('S', 'W')

    decimal
  end

  def parse_gps_coordinate(value)
    return nil if value.nil?

    # If already numeric, return as-is
    return value.to_f if value.is_a?(Numeric)

    # If it's a string, try parsing DMS format: "30 deg 30' 42.41\" N"
    return nil unless value.is_a?(String)

    # Match DMS format with direction
    if value =~ /(\d+)\s*deg\s*(\d+)'\s*([\d.]+)"\s*([NSEW])/i
      degrees = $1.to_f
      minutes = $2.to_f
      seconds = $3.to_f
      direction = $4.upcase

      # Convert to decimal degrees
      decimal = degrees + (minutes / 60.0) + (seconds / 3600.0)

      # Apply negative sign for South and West
      decimal = -decimal if direction == 'S' || direction == 'W'

      return decimal
    end

    # If string is already a decimal number, parse it
    value.to_f if value =~ /^-?\d+\.?\d*$/
  end

  def preprocess_thumbnail_variant
    return unless image_file.attached?
    return unless attachment_changed? || previous_changes.key?("id")

    # Pre-generate the commonly used thumbnail so views don't block on first access
    image_file.variant(
      resize_to_fill: [120, 120],
      format: :webp,
      saver: { strip: true, quality: 60, effort: 4 }
    ).processed
  rescue => e
    Rails.logger.info("[ImageMushroom##{id}] Variant pre-process skipped: #{e.class} - #{e.message}")
  end

end
