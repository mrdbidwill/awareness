# frozen_string_literal: true

namespace :storage do
  desc "Remove orphaned Active Storage blobs (blobs with no attachments)"
  task cleanup_orphaned: :environment do
    puts "Finding orphaned Active Storage blobs..."
    orphaned = ActiveStorage::Blob.left_joins(:attachments).where(active_storage_attachments: { id: nil })
    puts "Found #{orphaned.count} orphaned blobs"
    puts ""

    if orphaned.any?
      puts "Deleting orphaned blobs and their files..."
      count = 0

      orphaned.find_each do |blob|
        print "\rDeleting #{count + 1}/#{orphaned.count}..."

        begin
          # Purge deletes both the blob record and the file
          blob.purge
          count += 1
        rescue => e
          puts "\nError purging blob #{blob.id}: #{e.message}"
        end
      end

      puts "\n"
      puts "✓ Deleted #{count} orphaned blobs"
    else
      puts "No orphaned blobs found"
    end
  end
end
