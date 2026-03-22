# run with `rails taxonomy:advanced_extract`
namespace :taxonomy do
  desc "Advanced extraction of genus and species data with error handling"
  task advanced_extract: :environment do
    puts "Starting advanced taxonomic data extraction..."

    # Track statistics
    stats = {
      genera_created: 0,
      genera_updated: 0,
      species_created: 0,
      species_updated: 0,
      errors: []
    }

    ActiveRecord::Base.transaction do
      # Process genera first
      puts "Processing genera..."
      genus_records = MbList.where(rank_name: "gen.")

      genus_records.find_in_batches(batch_size: 1000) do |batch|
        batch.each do |record|
          begin
            genus = Genus.find_by(mblist_id: record.mblist_id)

            if genus
              genus.update!(taxon_name: record.taxon_name) if genus.taxon_name != record.taxon_name
              stats[:genera_updated] += 1
            else
              Genus.create!(
                mblist_id: record.mblist_id,
                taxon_name: record.taxon_name
              )
              stats[:genera_created] += 1
            end
          rescue => e
            stats[:errors] << "Genus error for #{record.taxon_name}: #{e.message}"
          end
        end

        puts "Processed #{stats[:genera_created] + stats[:genera_updated]} genera so far..."
      end

      # Process species
      puts "Processing species..."
      species_records = MbList.where(rank_name: "sp.")

      species_records.find_in_batches(batch_size: 1000) do |batch|
        batch.each do |record|
          begin
            # Extract genus name (first word of binomial name)
            taxon_parts = record.taxon_name.split
            next if taxon_parts.empty?

            genus_name = taxon_parts.first
            genus = Genus.find_by(taxon_name: genus_name)

            unless genus
              stats[:errors] << "Genus '#{genus_name}' not found for species '#{record.taxon_name}'"
              next
            end

            species = Species.find_by(taxon_name: record.taxon_name)

            if species
              # Update if necessary
              if species.mblist_id != record.mblist_id || species.genera_id != genus.id
                species.update!(
                  mblist_id: record.mblist_id,
                  genera_id: genus.id
                )
                stats[:species_updated] += 1
              end
            else
              Species.create!(
                mblist_id: record.mblist_id,
                taxon_name: record.taxon_name,
                genera_id: genus.id
              )
              stats[:species_created] += 1
            end
          rescue => e
            stats[:errors] << "Species error for #{record.taxon_name}: #{e.message}"
          end
        end

        puts "Processed #{stats[:species_created] + stats[:species_updated]} species so far..."
      end
    end

    # Print final statistics
    puts "\n=== EXTRACTION COMPLETE ==="
    puts "Genera created: #{stats[:genera_created]}"
    puts "Genera updated: #{stats[:genera_updated]}"
    puts "Species created: #{stats[:species_created]}"
    puts "Species updated: #{stats[:species_updated]}"
    puts "Errors: #{stats[:errors].length}"

    if stats[:errors].any?
      puts "\nErrors encountered:"
      stats[:errors].first(10).each { |error| puts "- #{error}" }
      puts "... and #{stats[:errors].length - 10} more errors" if stats[:errors].length > 10
    end
  end
end
