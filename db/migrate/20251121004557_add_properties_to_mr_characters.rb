class AddPropertiesToMrCharacters < ActiveRecord::Migration[8.0]
  def change
    # MySQL doesn't allow default values for JSON columns
    # The model will handle the default empty hash
    add_column :mr_characters, :properties, :json

    # Note: MySQL JSON columns can only be indexed via generated columns on specific JSON paths
    # If you need to query specific JSON keys frequently, add generated columns like:
    # add_column :mr_characters, :property_gill_attachment, :boolean, as: "JSON_EXTRACT(properties, '$.gill_attachment_required')", stored: true
    # add_index :mr_characters, :property_gill_attachment
    #
    # For now, we'll skip indexing and add specific indexes as needed based on usage patterns
  end
end
