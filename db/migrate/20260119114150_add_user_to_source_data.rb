class AddUserToSourceData < ActiveRecord::Migration[8.0]
  def change
    add_reference :source_data, :user, null: true, foreign_key: true
    add_index :source_data, [ :user_id, :source_data_type_id ]
  end
end
