# run with `rake taxonomy:extract_data`
namespace :taxonomy do
  desc "Extract genus and species data from mb_lists table"
  task extract_data: :environment do
    puts "Starting taxonomic data extraction..."

    # Extract genera
    puts "Processing genera..."
    genus_records = MbList.where(rank_name: "gen.")
    genus_count = 0

    genus_records.find_each do |record|
      genus = Genus.find_or_create_by(
        mblist_id: record.mblist_id,
        taxon_name: record.taxon_name
      )

      if genus.persisted?
        genus_count += 1
        puts "Created/found genus: #{genus.taxon_name}" if genus_count % 100 == 0
      end
    end

    puts "Processed #{genus_count} genera"

    # Extract species
    puts "Processing species..."
    species_records = MbList.where(rank_name: "sp.")
    species_count = 0

    species_records.find_each do |record|
      # Extract genus name from taxon_name (first word)
      genus_name = record.taxon_name.split.first
      genus = Genus.find_by(taxon_name: genus_name)

      if genus
        species = Species.find_or_create_by(
          taxon_name: record.taxon_name
        ) do |s|
          s.mblist_id = record.mblist_id
          s.genera_id = genus.id
        end

        if species.persisted?
          species_count += 1
          puts "Created/found species: #{species.taxon_name}" if species_count % 100 == 0
        end
      else
        puts "Warning: Genus '#{genus_name}' not found for species '#{record.taxon_name}'"
      end
    end

    puts "Processed #{species_count} species"
    puts "Taxonomic data extraction completed!"
  end
end