# frozen_string_literal: true

module DirectUploads
  class Validator
    Result = Struct.new(:ok?, :errors)

    def self.call(filename:, content_type:, byte_size:)
      errors = []

      if filename.to_s.strip.empty?
        errors << "Filename is required"
      end

      if content_type.to_s.strip.empty?
        errors << "Content type is required"
      elsif !ImageMushroom::ALLOWED_CONTENT_TYPES.include?(content_type)
        errors << "Unsupported content type: #{content_type}"
      end

      if byte_size.to_i <= 0
        errors << "Byte size is required"
      elsif byte_size.to_i > ImageMushroom::MAX_IMAGE_BYTES
        errors << "File is too large (max #{ImageMushroom::MAX_IMAGE_BYTES / 1.megabyte}MB)"
      end

      Result.new(errors.empty?, errors)
    end
  end
end
