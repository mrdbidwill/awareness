class CreateDnaSequences < ActiveRecord::Migration[8.0]
  def change
  create_table :dna_sequences do |t|
      t.references :mushroom, null: false, foreign_key: true
      t.text :notes
      t.text :dna_barcode_its
      t.string :genbank_number_url
      t.string :genbank_accession_number
      t.string :herbarium_catalog_number
      t.string :mycomap_blast_results
      t.string :provisional_species_name
      t.string :sequencing_technology
      t.string :trace_files_raw_dna_data
      t.string :voucher_number
      t.timestamps
    end
  end
end
