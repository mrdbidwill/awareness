# frozen_string_literal: true

require "active_storage/service/s3_service"

module ActiveStorage
  class Service::R2Service < Service::S3Service
    def initialize(**options)
      super
      # Cloudflare R2 does not support ACLs; remove any ACL option to prevent upload failures.
      @upload_options.delete(:acl) if instance_variable_defined?(:@upload_options)
    end

    def upload(key, io, checksum: nil, **options)
      super
    rescue => e
      # R2 rejects certain checksum combinations; retry without checksum when detected.
      if e.message.to_s.include?("only specify one non-default checksum") && checksum
        io.rewind if io.respond_to?(:rewind)
        super(key, io, checksum: nil, **options)
      else
        raise
      end
    end

    def public_url(key, **options)
      base = Rails.application.config.x.r2_public_base_url.to_s.strip
      return super if base.empty?

      "#{base.chomp("/")}/#{key}"
    end
  end
end
