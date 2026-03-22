require 'json'

namespace :glossary do
  desc "Import glossary terms from JSON file"
  task import: :environment do
    file_path = Rails.root.join('tmp', 'glossary_terms.json')

    unless File.exist?(file_path)
      puts "ERROR: File not found: #{file_path}"
      puts "\nTo create this file:"
      puts "1. Visit https://mushroomobserver.org/glossary_terms"
      puts "2. Open browser console (F12)"
      puts "3. Run the scraper script from lib/tasks/browser_scraper.js"
      puts "4. Copy the output and save to tmp/glossary_terms.json"
      exit
    end

    puts "Reading glossary terms from #{file_path}..."
    data = JSON.parse(File.read(file_path))

    imported_count = 0
    skipped_count = 0

    data.each do |entry|
      term_name = entry['term']
      definition = entry['definition']

      next if term_name.blank? || definition.blank?

      existing = Synonym.find_by(term: term_name)

      if existing
        puts "  Skipping duplicate: #{term_name}"
        skipped_count += 1
      else
        Synonym.create!(
          term: term_name,
          definition: definition,
          source: 'Mushroom Observer'
        )
        puts "  Imported: #{term_name}"
        imported_count += 1
      end
    end

    puts "\nImport complete!"
    puts "Imported: #{imported_count}"
    puts "Skipped: #{skipped_count}"
    puts "Total in database: #{Synonym.count}"
  end

  desc "Clear all glossary terms"
  task clear: :environment do
    count = Synonym.count
    Synonym.destroy_all
    puts "Deleted #{count} glossary terms"
  end
end
