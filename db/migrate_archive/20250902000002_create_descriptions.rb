class CreateDescriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :descriptions do |t|
      t.string :name
      t.text :description
      t.text :comments

      t.timestamps
    end
  end
end