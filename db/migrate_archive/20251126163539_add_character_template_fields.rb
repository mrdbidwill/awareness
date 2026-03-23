class AddCharacterTemplateFields < ActiveRecord::Migration[8.0]
  def change
    # Add template fields to mushrooms table
    add_column :mushrooms, :is_template, :boolean, default: false, null: false
    add_column :mushrooms, :template_name, :string
    add_column :mushrooms, :template_description, :text

    # Add index for finding templates quickly
    add_index :mushrooms, :is_template
    add_index :mushrooms, [:fungus_type_id, :is_template]
  end
end
