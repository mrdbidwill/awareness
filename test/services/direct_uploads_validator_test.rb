# frozen_string_literal: true

require "test_helper"

class DirectUploadsValidatorTest < ActiveSupport::TestCase
  test "accepts valid image upload" do
    result = DirectUploads::Validator.call(
      filename: "test.jpg",
      content_type: "image/jpeg",
      byte_size: 1024
    )

    assert result.ok?
    assert_empty result.errors
  end

  test "rejects invalid content type" do
    result = DirectUploads::Validator.call(
      filename: "test.pdf",
      content_type: "application/pdf",
      byte_size: 1024
    )

    assert_not result.ok?
    assert_includes result.errors.join, "Unsupported content type"
  end
end
