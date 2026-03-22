class CreateLookupTypes < ActiveRecord::Migration[8.0]
  def change
  create_table :lookup_types do |t|
      t.string :name
      t.text :description
      t.text :comments
      t.timestamps
    end
  end
end
