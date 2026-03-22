# frozen_string_literal: true

namespace :storage do
  desc "Migrate existing Active Storage files from local disk to S3"
  task migrate_to_s3: :environment do
    puts "Starting migration of Active Storage files to S3..."
    puts "=" * 80

    # Get the source and destination services
    source_service = ActiveStorage::Service::DiskService.new(root: Rails.root.join("storage"))
    dest_service = ActiveStorage::Blob.service

    # Verify destination is S3
    unless dest_service.is_a?(ActiveStorage::Service::S3Service)
      puts "ERROR: Destination service is not S3. Current service: #{dest_service.class}"
      puts "Make sure config.active_storage.service = :amazon in your environment"
      exit 1
    end

    # Get all blobs
    total_blobs = ActiveStorage::Blob.count
    migrated = 0
    skipped = 0
    errors = 0

    puts "Found #{total_blobs} blobs to process"
    puts "=" * 80

    ActiveStorage::Blob.find_each.with_index do |blob, index|
      print "\r[#{index + 1}/#{total_blobs}] Processing: #{blob.key[0..50]}..."

      begin
        # Check if file exists in S3
        if dest_service.exist?(blob.key)
          skipped += 1
          next
        end

        # Read file from local disk
        source_path = source_service.path_for(blob.key)
        unless File.exist?(source_path)
          puts "\n  WARNING: Source file not found: #{source_path}"
          errors += 1
          next
        end

        # Upload to S3
        File.open(source_path, "rb") do |file|
          dest_service.upload(
            blob.key,
            file,
            checksum: blob.checksum,
            content_type: blob.content_type,
            disposition: blob.content_disposition_with_filename,
            filename: blob.filename
          )
        end

        migrated += 1

        # Show progress every 50 files
        if (index + 1) % 50 == 0
          puts "\n  Progress: #{migrated} migrated, #{skipped} skipped, #{errors} errors"
        end

      rescue => e
        puts "\n  ERROR migrating #{blob.key}: #{e.message}"
        errors += 1
      end
    end

    puts "\n"
    puts "=" * 80
    puts "Migration complete!"
    puts "  Migrated: #{migrated} files"
    puts "  Skipped:  #{skipped} files (already in S3)"
    puts "  Errors:   #{errors} files"
    puts "=" * 80

    if errors > 0
      puts "\nWARNING: Some files had errors. Review the output above."
    else
      puts "\n✓ All files successfully migrated to S3!"
      puts "\nNext steps:"
      puts "1. Verify images display correctly on your site"
      puts "2. Once confirmed, you can delete local storage/ directory to free disk space"
      puts "   (Keep a backup until you're certain everything works)"
    end
  end

  desc "Verify all Active Storage blobs exist in current service"
  task verify_storage: :environment do
    puts "Verifying Active Storage files..."
    service = ActiveStorage::Blob.service

    puts "Current service: #{service.class}"
    puts "Total blobs: #{ActiveStorage::Blob.count}"
    puts "=" * 80

    missing = []

    ActiveStorage::Blob.find_each.with_index do |blob, index|
      print "\r[#{index + 1}/#{ActiveStorage::Blob.count}] Checking..."

      unless service.exist?(blob.key)
        missing << blob.key
        puts "\n  MISSING: #{blob.key}"
      end
    end

    puts "\n"
    puts "=" * 80
    if missing.empty?
      puts "✓ All #{ActiveStorage::Blob.count} files verified!"
    else
      puts "WARNING: #{missing.count} files are missing:"
      missing.each { |key| puts "  - #{key}" }
    end
    puts "=" * 80
  end
end
