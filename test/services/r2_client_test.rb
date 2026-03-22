# frozen_string_literal: true

require "test_helper"
require "aws-sdk-s3"

class R2ClientTest < ActiveSupport::TestCase
  setup do
    @client = Aws::S3::Client.new(stub_responses: true)
    @r2 = R2Client.new(
      bucket: "test-bucket",
      endpoint: "https://example.r2.cloudflarestorage.com",
      access_key_id: "key",
      secret_access_key: "secret",
      client: @client
    )

    @original_base = Rails.application.config.x.r2_public_base_url
    Rails.application.config.x.r2_public_base_url = "https://images.example.com"
  end

  teardown do
    Rails.application.config.x.r2_public_base_url = @original_base
  end

  test "put/get/delete object" do
    @client.stub_responses(:get_object, body: "ok")

    assert_nothing_raised do
      @r2.put_object(key: "test/key.txt", body: "ok", content_type: "text/plain")
    end

    response = @r2.get_object(key: "test/key.txt")
    assert_equal "ok", response.body.read

    assert_nothing_raised do
      @r2.delete_object(key: "test/key.txt")
    end
  end

  test "builds public url from base" do
    assert_equal "https://images.example.com/path/to/file.jpg", @r2.public_url("path/to/file.jpg")
  end
end
