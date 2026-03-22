# frozen_string_literal: true

module AdsenseHelper
  def adsense_enabled?
    ENV["ADSENSE_ENABLED"].to_s == "true" && ENV["ADSENSE_CLIENT_ID"].to_s.strip.present?
  end

  def adsense_client_id
    ENV["ADSENSE_CLIENT_ID"].to_s.strip
  end

  def render_adsense_script?
    adsense_enabled? && !user_signed_in?
  end
end
