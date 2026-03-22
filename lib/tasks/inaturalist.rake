namespace :inaturalist do
  desc "Import observation fields from CSV file in tmp/ directory"
  task import_observation_fields: :environment do
    csv_path = Rails.root.join('tmp', 'inaturalist_observation_fields.csv')

    unless File.exist?(csv_path)
      puts "Error: CSV file not found at #{csv_path}"
      puts "Please place the inaturalist_observation_fields.csv file in the tmp/ directory"
      exit 1
    end

    require 'csv'

    puts "Starting import from #{csv_path}..."
    start_time = Time.current
    imported_count = 0
    skipped_count = 0
    error_count = 0

    CSV.foreach(csv_path, headers: true) do |row|
      begin
        # Skip if already exists
        if InaturalistObservationField.exists?(inaturalist_id: row['id'])
          skipped_count += 1
          next
        end

        InaturalistObservationField.create!(
          inaturalist_id: row['id'],
          name: row['name'],
          datatype: row['datatype'],
          user_id: row['user_id'],
          description: row['description'],
          allowed_values: row['allowed_values'],
          values_count: row['values_count'],
          users_count: row['users_count'],
          uuid: row['uuid'],
          created_at: row['created_at'] || Time.current,
          updated_at: row['updated_at'] || Time.current
        )
        imported_count += 1

        # Progress indicator
        print '.' if imported_count % 100 == 0
        puts " #{imported_count}" if imported_count % 1000 == 0
      rescue => e
        error_count += 1
        puts "\nError importing row #{row['id']}: #{e.message}"
      end
    end

    elapsed_time = Time.current - start_time
    puts "\n"
    puts "=" * 60
    puts "Import completed in #{elapsed_time.round(2)} seconds"
    puts "Imported: #{imported_count}"
    puts "Skipped (already exist): #{skipped_count}"
    puts "Errors: #{error_count}"
    puts "Total records in database: #{InaturalistObservationField.count}"
    puts "=" * 60
  end

  desc "Clear all observation fields from database"
  task clear_observation_fields: :environment do
    print "This will delete all #{InaturalistObservationField.count} observation fields. Continue? (y/N): "
    response = STDIN.gets.chomp
    if response.downcase == 'y'
      InaturalistObservationField.delete_all
      puts "All observation fields deleted."
    else
      puts "Operation cancelled."
    end
  end
end
