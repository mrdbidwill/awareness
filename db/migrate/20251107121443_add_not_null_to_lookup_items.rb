class AddNotNullToLookupItems < ActiveRecord::Migration[8.0]
  def up
    # Get the first available mr_character_id and source_data_id
    first_mr_character_id = MrCharacter.minimum(:id)
    first_source_data_id = SourceData.minimum(:id)

    # Update NULL values with first available IDs
    # You may want to review these records and set appropriate values manually
    LookupItem.where(mr_character_id: nil).update_all(mr_character_id: first_mr_character_id)
    LookupItem.where(source_data_id: nil).update_all(source_data_id: first_source_data_id)

    # Now add the NOT NULL constraints
    change_column_null :lookup_items, :mr_character_id, false
    change_column_null :lookup_items, :source_data_id, false
  end

  def down
    # Remove NOT NULL constraints
    change_column_null :lookup_items, :mr_character_id, true
    change_column_null :lookup_items, :source_data_id, true
  end
end
