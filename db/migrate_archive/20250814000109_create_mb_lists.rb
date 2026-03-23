class CreateMbLists < ActiveRecord::Migration[8.0] # Adjust version as per your Rails app
  def change
  create_table :mb_lists do |t|
      t.text :mblist_id
      t.text :taxon_name
      t.text :authors
      t.text :rank_name
      t.text :year_of_effective_publication   # data contains question marks
      t.text :name_status
      t.text :mycobank_number
      t.text :hyperlink
      t.text :classification
      t.text :current_name
      t.text :synonymy
    end
  execute <<-SQL
      ALTER TABLE mb_lists
      CONVERT TO CHARACTER SET utf8mb4
      COLLATE utf8mb4_0900_as_cs;
    SQL

    # Add indexes with a specified key length for TEXT columns
    add_index :mb_lists, [:taxon_name, :rank_name], name: "index_mblists_on_taxon_name_and_rank_name", length: { taxon_name: 255, rank_name: 255 }
    add_index :mb_lists, :taxon_name, name: "index_mblists_on_taxon_name", length: 255
    add_index :mb_lists, :rank_name, name: "index_mblists_on_rank_name", length: 255
    add_index :mb_lists, :name_status, name: "index_mblists_on_name_status", length: 255
  end
end

