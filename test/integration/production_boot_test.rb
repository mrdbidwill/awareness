# frozen_string_literal: true

require "test_helper"
require "open3"

class ProductionBootTest < ActionDispatch::IntegrationTest
  test "application boots successfully in production mode" do
    db_host = ENV.fetch("DB_HOST", "127.0.0.1")
    db_user = ENV.fetch("MYSQL_USER", "awareness_user")
    db_password = ENV.fetch("MYSQL_PASSWORD", "devpassword")
    db_name = ENV.fetch("PRODUCTION_BOOT_DB", "awareness_test")

    database_url = ENV.fetch(
      "PRODUCTION_BOOT_DATABASE_URL",
      "mysql2://#{db_user}:#{db_password}@#{db_host}/#{db_name}"
    )

    env = {
      "RAILS_ENV" => "production",
      "DATABASE_URL" => database_url,
      "SECRET_KEY_BASE" => "test-secret-key-base",
      "RAILS_LOG_TO_STDOUT" => "1"
    }

    stdout, stderr, status = Open3.capture3(env, "bin/rails", "runner", "puts 'booted'")

    assert status.success?, "Production boot failed. stdout=#{stdout} stderr=#{stderr}"
    assert_includes stdout, "booted"
  end

  test "public pages are accessible without authentication" do
    public_pages = {
      "root" => root_path,
      "articles" => articles_path,
      "books" => books_path,
      "contact" => contact_path,
      "newsletter" => new_newsletter_path
    }

    public_pages.each do |name, path|
      get path
      assert_response :success, "#{name} (#{path}) should be publicly accessible"
      assert_not_includes response.body, "Internal Server Error"
    end
  end

  test "admin pages redirect when not authenticated" do
    get admin_root_path
    assert_redirected_to new_user_session_path
  end
end
