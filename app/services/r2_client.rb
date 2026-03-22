# frozen_string_literal: true

require "aws-sdk-s3"

class R2Client
  DEFAULT_REGION = "auto"
  REQUIRED_ENV = %w[R2_BUCKET R2_ENDPOINT R2_ACCESS_KEY_ID R2_SECRET_ACCESS_KEY].freeze

  def self.validate_env!
    missing = REQUIRED_ENV.select { |key| ENV[key].to_s.strip.empty? }
    return if missing.empty?

    raise "Missing required R2 env vars: #{missing.join(', ')}"
  end

  def initialize(
    bucket: ENV["R2_BUCKET"],
    endpoint: ENV["R2_ENDPOINT"],
    access_key_id: ENV["R2_ACCESS_KEY_ID"],
    secret_access_key: ENV["R2_SECRET_ACCESS_KEY"],
    region: ENV.fetch("R2_REGION", DEFAULT_REGION),
    client: nil
  )
    @bucket = bucket
    @endpoint = endpoint
    @access_key_id = access_key_id
    @secret_access_key = secret_access_key
    @region = region
    @client = client
  end

  def put_object(key:, body:, content_type: nil, cache_control: nil)
    client.put_object(
      bucket: bucket,
      key: key,
      body: body,
      content_type: content_type,
      cache_control: cache_control
    )
  end

  def get_object(key:)
    client.get_object(bucket: bucket, key: key)
  end

  def delete_object(key:)
    client.delete_object(bucket: bucket, key: key)
  end

  def object_exists?(key:)
    client.head_object(bucket: bucket, key: key)
    true
  rescue Aws::S3::Errors::NotFound
    false
  end

  def presign_put(key:, content_type:, expires_in: 900)
    presigner.presigned_url(
      :put_object,
      bucket: bucket,
      key: key,
      content_type: content_type,
      expires_in: expires_in
    )
  end

  def public_url(key)
    base = Rails.application.config.x.r2_public_base_url.to_s.strip
    return nil if base.empty?

    "#{base.chomp("/")}/#{key}"
  end

  private

  attr_reader :bucket, :endpoint, :access_key_id, :secret_access_key, :region

  def client
    @client ||= Aws::S3::Client.new(
      endpoint: endpoint,
      region: region,
      access_key_id: access_key_id,
      secret_access_key: secret_access_key,
      force_path_style: true
    )
  end

  def presigner
    @presigner ||= Aws::S3::Presigner.new(client: client)
  end
end
