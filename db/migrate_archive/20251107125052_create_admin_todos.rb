class CreateAdminTodos < ActiveRecord::Migration[8.0]
  def change
    create_table :admin_todos do |t|
      t.string :title, null: false
      t.text :description
      t.boolean :done, default: false, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :admin_todos, :done
    add_index :admin_todos, :created_at
  end
end
