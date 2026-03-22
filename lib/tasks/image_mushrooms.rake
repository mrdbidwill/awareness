namespace :image_mushrooms do
  desc "Extract EXIF data (including date_taken and GPS location) for existing images"
  task extract_exif: :environment do
    count = 0
    updated = 0
    skipped = 0

    puts "Processing existing ImageMushroom records..."

    ImageMushroom.find_each do |im|
      count += 1

      unless im.image_file.attached?
        skipped += 1
        next
      end

      # Extract EXIF for images missing date_taken or location
      if im.date_taken.nil? || im.latitude.nil? || im.longitude.nil?
        print "Processing ImageMushroom ##{im.id}... "
        begin
          im.send(:extract_and_store_exif)
          info = []
          info << "date_taken: #{im.date_taken}" if im.date_taken.present?
          info << "location: #{im.latitude}, #{im.longitude}" if im.latitude.present? && im.longitude.present?

          if info.any?
            puts "✓ (#{info.join(', ')})"
            updated += 1
          else
            puts "✓ (no EXIF data found)"
            updated += 1
          end
        rescue => e
          puts "✗ (#{e.message})"
        end
      end
    end

    puts "\nComplete!"
    puts "Total records: #{count}"
    puts "Updated: #{updated}"
    puts "Skipped (no attachment): #{skipped}"
    puts "Already had complete data: #{count - updated - skipped}"
  end
end
