# frozen_string_literal: true

class DirectUploadsController < ApplicationController
  before_action :authenticate_user!
  skip_after_action :verify_authorized, raise: false

  def create
    ActiveStorage::Current.url_options = {
      host: request.host,
      protocol: request.protocol,
      port: request.optional_port
    }

    blob_params = params.require(:blob).permit(:filename, :byte_size, :checksum, :content_type, metadata: {})
    context = params[:context].presence || blob_params.dig(:metadata, :context).presence || "mushroom"

    validation = DirectUploads::Validator.call(
      filename: blob_params[:filename],
      content_type: blob_params[:content_type],
      byte_size: blob_params[:byte_size]
    )

    unless validation.ok?
      Rails.logger.info(
        "[DirectUploads] rejected user=#{current_user.id} errors=#{validation.errors.join('; ')}"
      )
      render json: { errors: validation.errors }, status: :unprocessable_entity and return
    end

    key = build_storage_key(blob_params[:filename], context)

    blob = ActiveStorage::Blob.create_before_direct_upload!(
      filename: blob_params[:filename],
      byte_size: blob_params[:byte_size],
      checksum: blob_params[:checksum],
      content_type: blob_params[:content_type],
      metadata: blob_params[:metadata],
      key: key
    )

    Rails.logger.info(
      "[DirectUploads] issued user=#{current_user.id} key=#{blob.key} size=#{blob.byte_size} content_type=#{blob.content_type}"
    )

    render json: {
      # ActiveStorage expects `signed_id` in the direct upload response.
      signed_id: blob.signed_id,
      blob_signed_id: blob.signed_id,
      key: blob.key,
      filename: blob.filename.to_s,
      content_type: blob.content_type,
      byte_size: blob.byte_size,
      checksum: blob.checksum,
      direct_upload: {
        url: blob.service_url_for_direct_upload,
        headers: blob.service_headers_for_direct_upload
      },
      public_url: R2Client.new.public_url(blob.key)
    }
  end

  private

  def build_storage_key(filename, context)
    safe_name = filename.to_s.strip
    extension = File.extname(safe_name).downcase
    safe_context = context.to_s.parameterize.presence || "mushroom"
    date_prefix = Time.current.utc.strftime("%Y/%m/%d")

    "uploads/#{safe_context}/#{date_prefix}/#{SecureRandom.uuid}#{extension}"
  end
end
