# frozen_string_literal: true

require "active_storage/service/disk_service"

namespace :r2 do
  desc "Smoke test R2 connectivity (put/get/delete)"
  task smoke: :environment do
    R2Client.validate_env!
    client = R2Client.new

    key = "smoke/#{Time.current.utc.strftime('%Y%m%d')}/#{SecureRandom.uuid}.txt"
    body = "r2-smoke-#{Time.current.utc.iso8601}"

    puts "Uploading test object to R2..."
    client.put_object(key: key, body: body, content_type: "text/plain")

    puts "Reading test object from R2..."
    response = client.get_object(key: key)
    content = response.body.read

    unless content == body
      raise "Smoke test failed: content mismatch"
    end

    puts "Deleting test object from R2..."
    client.delete_object(key: key)

    puts "✓ R2 smoke test passed"
  end

  desc "Backfill Active Storage blobs from local disk to current service (idempotent)"
  task backfill: :environment do
    source_service = ActiveStorage::Service::DiskService.new(root: Rails.root.join("storage"))
    dest_service = ActiveStorage::Blob.service

    unless dest_service.is_a?(ActiveStorage::Service::S3Service)
      puts "ERROR: Destination service is not S3-compatible. Current: #{dest_service.class}"
      puts "Set ACTIVE_STORAGE_SERVICE=r2 and try again."
      exit 1
    end

    batch_size = ENV.fetch("BATCH_SIZE", 200).to_i
    start_after_id = ENV["START_AFTER_ID"].to_i
    verify = ENV["VERIFY"].to_s == "true"
    dry_run = ENV["DRY_RUN"].to_s == "true"

    scope = ActiveStorage::Blob.order(:id)
    scope = scope.where("id > ?", start_after_id) if start_after_id.positive?

    total = scope.count
    processed = 0
    migrated = 0
    skipped = 0
    errors = 0

    puts "Backfill starting: total=#{total} batch_size=#{batch_size} start_after_id=#{start_after_id}"

    scope.find_in_batches(batch_size: batch_size) do |batch|
      batch.each do |blob|
        processed += 1
        begin
          if dest_service.exist?(blob.key)
            skipped += 1
            next
          end

          source_path = source_service.path_for(blob.key)
          unless File.exist?(source_path)
            errors += 1
            puts "Missing source file for blob=#{blob.id} key=#{blob.key}"
            next
          end

          if dry_run
            migrated += 1
            next
          end

          File.open(source_path, "rb") do |file|
            upload_params = {
              content_type: blob.content_type,
              disposition: (blob.respond_to?(:content_disposition_with_filename) ? blob.content_disposition_with_filename : nil),
              filename: blob.filename
            }
            upload_params[:checksum] = blob.checksum if blob.checksum.present?

            begin
              dest_service.upload(blob.key, file, **upload_params)
            rescue => e
              if e.message.include?("only specify one non-default checksum") && upload_params.key?(:checksum)
                upload_params.delete(:checksum)
                file.rewind
                dest_service.upload(blob.key, file, **upload_params)
              else
                raise
              end
            end
          end

          if verify && !dest_service.exist?(blob.key)
            raise "Verification failed for blob=#{blob.id} key=#{blob.key}"
          end

          migrated += 1
        rescue => e
          errors += 1
          puts "ERROR blob=#{blob.id} key=#{blob.key}: #{e.class} #{e.message}"
        end
      end

      puts "Progress: processed=#{processed} migrated=#{migrated} skipped=#{skipped} errors=#{errors}"
    end

    puts "Backfill complete: processed=#{processed} migrated=#{migrated} skipped=#{skipped} errors=#{errors}"
  end
end
