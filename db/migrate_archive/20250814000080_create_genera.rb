class CreateGenera < ActiveRecord::Migration[8.0]
  def change
    create_table :genera do |t|
      t.string :mblist_id
      t.string :name
      t.timestamps
    end
  end
end
