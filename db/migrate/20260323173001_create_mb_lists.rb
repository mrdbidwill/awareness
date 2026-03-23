class CreateMbLists < ActiveRecord::Migration[8.0]
  def up
    return if table_exists?(:mb_lists)

    create_table :mb_lists do |t|
      t.text :mblist_id
      t.text :taxon_name
      t.text :authors
      t.text :rank_name
      t.text :year_of_effective_publication
      t.text :name_status
      t.text :mycobank_number
      t.text :hyperlink
      t.text :classification
      t.text :current_name
      t.text :synonymy
      t.timestamps
    end

    # Set character encoding for UTF-8 support (MySQL/MariaDB)
    execute <<-SQL
      ALTER TABLE mb_lists
      CONVERT TO CHARACTER SET utf8mb4
      COLLATE utf8mb4_0900_as_cs;
    SQL

    # Add indexes for performance
    add_index :mb_lists, [:taxon_name, :rank_name],
              name: "index_mblists_on_taxon_name_and_rank_name",
              length: { taxon_name: 255, rank_name: 255 }
    add_index :mb_lists, :taxon_name,
              name: "index_mblists_on_taxon_name",
              length: 255
    add_index :mb_lists, :rank_name,
              name: "index_mblists_on_rank_name",
              length: 255
    add_index :mb_lists, :name_status,
              name: "index_mblists_on_name_status",
              length: 255
  end

  def down
    drop_table :mb_lists, if_exists: true
  end
end
