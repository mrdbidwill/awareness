namespace :inaturalist do
  desc "Download all observation fields from iNaturalist API and output to CSV"
  task observation_fields: :environment do
    require 'net/http'
    require 'json'
    require 'csv'

    api_url = 'https://www.inaturalist.org/observation_fields.json'
    output_file = Rails.root.join('tmp', 'inaturalist_observation_fields.csv')

    puts "Fetching observation fields from iNaturalist..."
    puts "This may take 10-15 minutes to complete..."

    CSV.open(output_file, 'w', headers: true) do |csv|
      # Write headers
      csv << ['id', 'name', 'datatype', 'user_id', 'description', 'created_at',
              'updated_at', 'allowed_values', 'values_count', 'users_count', 'uuid']

      page = 1
      total_fields = 0

      # Based on forum post, there are ~660 pages
      loop do
        begin
          # Add delay to be respectful to the API
          sleep(1) if page > 1

          uri = URI("#{api_url}?page=#{page}")
          response = Net::HTTP.get_response(uri)

          unless response.is_a?(Net::HTTPSuccess)
            puts "Error on page #{page}: #{response.code} #{response.message}"
            break
          end

          fields = JSON.parse(response.body)

          # Empty response means we've reached the end
          break if fields.empty?

          fields.each do |field|
            csv << [
              field['id'],
              field['name'],
              field['datatype'],
              field['user_id'],
              field['description'],
              field['created_at'],
              field['updated_at'],
              field['allowed_values'],
              field['values_count'],
              field['users_count'],
              field['uuid']
            ]
            total_fields += 1
          end

          print "\rProcessed page #{page} (#{total_fields} fields total)"
          page += 1

        rescue StandardError => e
          puts "\nError on page #{page}: #{e.message}"
          puts "Continuing to next page..."
          page += 1
          next
        end
      end

      puts "\n\nCompleted! Downloaded #{total_fields} observation fields"
      puts "Output saved to: #{output_file}"
    end
  end
end
