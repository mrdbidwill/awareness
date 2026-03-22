# frozen_string_literal: true

require Rails.root.join("app/services/active_storage/service/r2_service").to_s

Rails.application.config.x.r2_public_base_url =
  ENV["R2_PUBLIC_BASE_URL"].to_s.strip.presence&.chomp("/")

if Rails.env.production? && ENV.fetch("ACTIVE_STORAGE_SERVICE", nil) == "r2"
  required = %w[
    R2_BUCKET
    R2_ENDPOINT
    R2_ACCESS_KEY_ID
    R2_SECRET_ACCESS_KEY
    R2_PUBLIC_BASE_URL
  ]

  missing = required.select { |key| ENV[key].to_s.strip.empty? }

  unless missing.empty?
    message = "Missing required R2 env vars in production: #{missing.join(', ')}"
    Rails.logger.fatal(message)
    raise message
  end

  base_url = Rails.application.config.x.r2_public_base_url
  unless base_url&.start_with?("http://", "https://")
    message = "R2_PUBLIC_BASE_URL must include http(s) scheme (got: #{ENV['R2_PUBLIC_BASE_URL'].inspect})"
    Rails.logger.fatal(message)
    raise message
  end
end
