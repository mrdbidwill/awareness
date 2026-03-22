class AddFungusTypeToMrCharacters < ActiveRecord::Migration[8.0]
  def up
    # Add fungus_type_id column (nullable - NULL means applies to all fungus types)
    unless column_exists?(:mr_characters, :fungus_type_id)
      add_reference :mr_characters, :fungus_type, null: true, foreign_key: true, index: true
    end

    # Set default for all existing characters to fungus_type_id = 7 (Gills)
    # This is accurate for all 657 current characters
    gills = FungusType.find_by(name: 'Gills')

    if gills
      MrCharacter.where(fungus_type_id: nil).update_all(fungus_type_id: gills.id)
      say "Set all existing characters to fungus_type_id = #{gills.id} (Gills)"
    else
      say "Warning: 'Gills' fungus type not found. Existing characters left with NULL fungus_type_id.", true
    end
  end

  def down
    remove_reference :mr_characters, :fungus_type, foreign_key: true, index: true if column_exists?(:mr_characters, :fungus_type_id)
  end
end
