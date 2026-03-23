# frozen_string_literal: true

require 'active_support/core_ext/integer/time'

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot for better performance and memory savings (ignored by Rake tasks).
  config.eager_load = true

  # Full error reports are disabled.
  config.consider_all_requests_local = false

  # Turn on fragment caching in view templates.
  config.action_controller.perform_caching = true

  # Cache assets for far-future expiry since they are all digest stamped.
  config.public_file_server.headers = { 'cache-control' => "public, max-age=#{1.year.to_i}" }

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = "http://assets.example.com"

  # Store uploaded files on the configured Active Storage service (see config/storage.yml for options).
  config.active_storage.service = ENV.fetch("ACTIVE_STORAGE_SERVICE", "local").to_sym
  config.active_storage.resolve_model_to_route = :rails_storage_redirect

  # Assume all access to the app is happening through a SSL-terminating reverse proxy.
  config.assume_ssl = true

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  # Skip http-to-https redirect for the default health check endpoint.
  # config.ssl_options = { redirect: { exclude: ->(request) { request.path == "/up" } } }

  # Log to STDOUT with the current request id as a default log tag.
  config.log_tags = [:request_id]
  config.logger   = ActiveSupport::TaggedLogging.logger($stdout)

  # Change to "debug" to log everything (including potentially personally-identifiable information!)
  config.log_level = ENV.fetch('RAILS_LOG_LEVEL', 'info')

  # Prevent health checks from clogging up the logs.
  config.silence_healthcheck_path = '/up'

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # Replace the default in-process memory cache store with a durable alternative.
  config.cache_store = :solid_cache_store

  # ============================================================================
  # SOLID QUEUE CONFIGURATION - CRITICAL FOR PRODUCTION
  # ============================================================================
  # IMPORTANT: This application uses Solid Queue (DB-backed job queue) in production.
  #
  # REQUIRED DATABASES (must exist and be migrated):
  # - awareness_production_queue: Stores background jobs (see database.yml:64-67)
  # - awareness_production_cache: Stores cached data (see database.yml:60-63)
  # - awareness_production_cable: Stores ActionCable data (see database.yml:68-71)
  #
  # ⚠️  CRITICAL - DO NOT CHANGE TO :async OR :sidekiq
  # Using :async (in-memory queue) will cause 500 errors because the config below
  # tries to connect to the queue database. Mismatch = initialization failure.
  #
  # SYMPTOMS OF MISCONFIGURATION:
  # - 500 Internal Server Error on all pages
  # - "ActiveRecord::ConnectionNotEstablished" errors
  # - Puma fails to start or crashes on first request
  #
  # TO VERIFY CORRECT SETUP ON PRODUCTION:
  # 1. Check databases exist: mysql -e "SHOW DATABASES LIKE 'awareness_production_%';"
  # 2. Check queue tables: mysql awareness_production_queue -e "SHOW TABLES;"
  # 3. Should see 13 solid_queue_* tables
  #
  # TROUBLESHOOTING:
  # - If queue DB missing: RAILS_ENV=production rails solid_queue:install
  # - If tables missing: RAILS_ENV=production rails db:migrate:queue
  # ============================================================================
  config.active_job.queue_adapter = :solid_queue  # CRITICAL: Must be :solid_queue (not :async)
  config.solid_queue.connects_to = { database: { writing: :queue } }

  # Required for encrypted attributes (e.g., devise-two-factor otp_secret).
  config.active_record.encryption.primary_key =
    ENV["ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY"].presence ||
    Rails.application.credentials.dig(:active_record_encryption, :primary_key)
  config.active_record.encryption.deterministic_key =
    ENV["ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY"].presence ||
    Rails.application.credentials.dig(:active_record_encryption, :deterministic_key)
  config.active_record.encryption.key_derivation_salt =
    ENV["ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT"].presence ||
    Rails.application.credentials.dig(:active_record_encryption, :key_derivation_salt)

  # Keep 2FA encryption key aligned even when ENV is not explicitly set.
  if ENV["OTP_SECRET_ENCRYPTION_KEY"].blank?
    ENV["OTP_SECRET_ENCRYPTION_KEY"] =
      Rails.application.credentials.dig(:otp_secret_encryption_key).presence ||
      Rails.application.credentials.dig(:active_record_encryption, :primary_key).to_s
  end

  default_host = ENV.fetch("APP_HOST", "awareness.mrdbid.com")
  config.action_mailer.default_url_options = { host: default_host, protocol: "https" }

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.deliver_later_queue_name = :mailers
  config.action_mailer.perform_deliveries = true

  # Skip credentials during asset precompilation
  unless defined?(Rails::Console) || File.basename($0) == "rake" && ARGV.include?("assets:precompile")
    config.action_mailer.smtp_settings = {
      address:              Rails.application.credentials.dig(:smtp, :address) || "localhost",
      port:                 Rails.application.credentials.dig(:smtp, :port) || 25,
      user_name:            Rails.application.credentials.dig(:smtp, :user_name),
      password:             Rails.application.credentials.dig(:smtp, :password),
      authentication:       Rails.application.credentials.dig(:smtp, :authentication) || "login",
      enable_starttls_auto: Rails.application.credentials.dig(:smtp, :enable_starttls_auto) != false
    }
    config.action_mailer.default_options = {
      from: Rails.application.credentials.dig(:smtp, :from) || "no-reply@awareness.mrdbid.com"
    }
  end
  config.action_mailer.default_url_options = { host: ENV["APP_HOST"] || default_host, protocol: "https" }


  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Only use :id for inspections in production.
  config.active_record.attributes_for_inspect = [:id]

  # Enable DNS rebinding protection and other `Host` header attacks.
  config.hosts = [default_host, "www.#{default_host}", /.*\.#{Regexp.escape(default_host)}/, "localhost"]

  # Skip DNS rebinding protection for the default health check endpoint.
  config.host_authorization = { exclude: ->(request) { request.path == "/up" } }

   # Ensure assets are handled by Rails
   config.assets.css_compressor = nil # Tailwind doesn't need CSS compression
   config.assets.compile = true
   config.assets.digest = true
   config.assets.debug = false
end
