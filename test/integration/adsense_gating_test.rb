# frozen_string_literal: true

require "test_helper"

class AdsenseGatingTest < ActionDispatch::IntegrationTest
  setup do
    @original_enabled = ENV["ADSENSE_ENABLED"]
    @original_client_id = ENV["ADSENSE_CLIENT_ID"]
    ENV["ADSENSE_ENABLED"] = "true"
    ENV["ADSENSE_CLIENT_ID"] = "ca-pub-1234567890"
  end

  teardown do
    ENV["ADSENSE_ENABLED"] = @original_enabled
    ENV["ADSENSE_CLIENT_ID"] = @original_client_id
  end

  test "adsense script is included for public pages" do
    get root_path
    assert_response :success
    assert_includes response.body, "pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"
    assert_includes response.body, "ca-pub-1234567890"
  end

  test "adsense script is excluded for authenticated pages" do
    sign_in users(:one)
    get root_path
    assert_response :success
    assert_not_includes response.body, "pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"
  end
end
