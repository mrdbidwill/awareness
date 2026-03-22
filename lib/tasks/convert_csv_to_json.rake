namespace :inaturalist do
  desc "Convert observation fields CSV to JSON"
  task csv_to_json: :environment do
    require 'csv'
    require 'json'

    csv_file = Rails.root.join('data', 'inaturalist', 'observation_fields.csv')
    json_file = Rails.root.join('data', 'inaturalist', 'observation_fields.json')

    puts "Converting CSV to JSON..."

    fields = []
    CSV.foreach(csv_file, headers: true) do |row|
      fields << row.to_h
    end

    File.write(json_file, JSON.pretty_generate(fields))

    puts "Completed! Created #{json_file}"
    puts "Total fields: #{fields.count}"
  end
end
