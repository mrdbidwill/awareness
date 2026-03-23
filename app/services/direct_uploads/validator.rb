# frozen_string_literal: true

module DirectUploads
  class Validator
    Result = Struct.new(:ok?, :errors)
    ALLOWED_CONTENT_TYPES = %w[
      image/jpeg
      image/jpg
      image/png
      image/webp
      image/gif
      image/heic
      image/heif
    ].freeze
    MAX_UPLOAD_BYTES = 20.megabytes

    def self.call(filename:, content_type:, byte_size:)
      errors = []

      if filename.to_s.strip.empty?
        errors << "Filename is required"
      end

      if content_type.to_s.strip.empty?
        errors << "Content type is required"
      elsif !ALLOWED_CONTENT_TYPES.include?(content_type)
        errors << "Unsupported content type: #{content_type}"
      end

      if byte_size.to_i <= 0
        errors << "Byte size is required"
      elsif byte_size.to_i > MAX_UPLOAD_BYTES
        errors << "File is too large (max #{MAX_UPLOAD_BYTES / 1.megabyte}MB)"
      end

      Result.new(errors.empty?, errors)
    end
  end
end
