# frozen_string_literal: true

require "test_helper"
require "base64"
require "digest"

class DirectUploadsRequestTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @checksum = Base64.strict_encode64(Digest::MD5.digest("direct-upload-test"))
  end

  test "direct uploads require authentication" do
    post direct_uploads_path, params: { blob: { filename: "test.jpg" } }
    assert_redirected_to new_user_session_path
  end

  test "direct uploads reject unsupported content type" do
    sign_in @user

    post direct_uploads_path,
         params: {
           blob: {
             filename: "test.pdf",
             content_type: "application/pdf",
             byte_size: 1024,
             checksum: @checksum
           }
         }

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_includes json["errors"].join, "Unsupported content type"
  end

  test "direct uploads reject oversized file" do
    sign_in @user

    post direct_uploads_path,
         params: {
           blob: {
             filename: "large.jpg",
             content_type: "image/jpeg",
             byte_size: ImageMushroom::MAX_IMAGE_BYTES + 1,
             checksum: @checksum
           }
         }

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_includes json["errors"].join, "File is too large"
  end

  test "direct uploads return presign data for valid request" do
    sign_in @user

    post direct_uploads_path,
         params: {
           blob: {
             filename: "test.jpg",
             content_type: "image/jpeg",
             byte_size: 1024,
             checksum: @checksum
           }
         }

    assert_response :success
    json = JSON.parse(response.body)
    assert json["key"].present?
    assert json["direct_upload"]["url"].present?
    assert json["direct_upload"]["headers"].is_a?(Hash)
  end
end
