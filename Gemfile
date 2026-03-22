# frozen_string_literal: true

source 'https://rubygems.org'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 8.0.2'
# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem 'propshaft'
# Use mysql as the database for Active Record
gem 'mysql2', '~> 0.5'
# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '>= 5.0'
# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem 'importmap-rails'
# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem 'turbo-rails'
# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem 'stimulus-rails'
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem 'jbuilder'
gem "image_processing", "~> 1.2"
gem 'paper_trail', '~> 16.0' # or the latest version
gem 'kaminari' # pagination
gem 'ruby-vips', '~> 2.1'
gem "exifr" # EXIF parsing for JPEG/TIFF images
gem "mini_exiftool"   # Robust fallback for HEIC/RAW via exiftool
gem "dotenv-rails"
gem "capistrano"
gem "capistrano-rails"
gem "capistrano-rbenv"
gem "capistrano-bundler"
gem "capistrano-puma"

gem 'csv'
gem 'sitemap_generator' # Generate XML sitemap for search engines
gem 'auto_glossary', '>= 0.1.1' # Auto-glossary for mycological terms - created by mrdbid
gem 'mycowriter', '~> 0.1.8'    # Adds genus species suggestions - created by mrdbid

gem 'i18n', '~> 1.14'
gem 'carmen-rails', '~> 1.0'

gem 'devise'                        # Authentication
gem 'devise-two-factor', '~> 6.1.0' # Two-factor authentication
gem 'pundit'                        # Permissions and policies
gem 'tailwindcss-rails'             # Tailwind CSS
gem 'rqrcode'                       # ### **Integrate with OTP Apps (e.g., Google Authenticator)**

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[windows jruby]

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem 'solid_cable'
gem 'solid_cache'
gem 'solid_queue'

gem 'roo' # Read Excel files

# PDF generation
gem 'prawn'
gem 'prawn-table'

# ZIP file creation for user exports
gem 'rubyzip', '~> 2.3'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# AWS SDK for S3 storage
gem 'aws-sdk-s3', '~> 1', require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem 'kamal', require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem 'thruster', require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

group :development, :test do
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'factory_bot_rails'

  gem "letter_opener"
  gem "letter_opener_web"

  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[mri windows], require: 'debug/prelude'
  # gem 'guard-rspec', require: false

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem 'brakeman', require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false

  gem 'rubocop', '~> 1.78.0', require: false
  gem 'rubocop-rails', '~> 2.21.0', require: false
  gem 'rubocop-performance', '~> 1.16.0', require: false
  gem 'rubocop-capybara', '~> 2.22.0', require: false

  gem 'reek', require: false
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'web-console'
end

group :test do
  gem 'minitest'
  gem 'minitest-reporters', '~> 1.4' # Better test output
  gem 'minitest-rails'             # Adds Minitest integration with Rails
  gem 'rails-controller-testing', '~> 1.0' # For controller tests if needed
  gem 'simplecov', require: false  # Code coverage
  gem 'simplecov-lcov', require: false  # LCOV formatter for CI
  gem 'mutant-minitest'            # Mutation testing
  gem 'bullet'                     # N+1 query detection
  gem 'webmock'                    # HTTP request stubbing
  gem 'vcr'                        # Record HTTP interactions
end

gem "tailwindcss-ruby", "~> 4.1"
