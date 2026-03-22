class RenameLookuTypesToObservationMethods < ActiveRecord::Migration[8.0]
  def change
    # Rename the table
    rename_table :lookup_types, :observation_methods

    # Rename the foreign key column in mr_characters
    rename_column :mr_characters, :lookup_type_id, :observation_method_id
  end
end
