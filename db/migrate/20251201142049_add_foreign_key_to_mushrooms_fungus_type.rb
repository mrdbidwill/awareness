class AddForeignKeyToMushroomsFungusType < ActiveRecord::Migration[8.0]
  def up
    # First, ensure all existing mushrooms have valid fungus_type_id references
    # Update any orphaned records to a default fungus_type or handle them appropriately
    invalid_mushrooms = Mushroom.where.not(fungus_type_id: FungusType.pluck(:id))

    if invalid_mushrooms.exists?
      puts "WARNING: Found #{invalid_mushrooms.count} mushrooms with invalid fungus_type_id:"
      invalid_mushrooms.find_each do |mushroom|
        puts "  - Mushroom ID: #{mushroom.id}, Name: #{mushroom.name}, Invalid fungus_type_id: #{mushroom.fungus_type_id}"
      end

      # Try to find a default fungus_type (e.g., "Gasteroids" which is ID 1 in your case)
      default_fungus_type = FungusType.find_by(id: 1) || FungusType.first

      if default_fungus_type
        puts "Updating invalid mushrooms to use fungus_type: #{default_fungus_type.name} (ID: #{default_fungus_type.id})"
        invalid_mushrooms.update_all(fungus_type_id: default_fungus_type.id)
      else
        raise "Cannot add foreign key: Found mushrooms with invalid fungus_type_id and no default fungus_type available"
      end
    end

    # Now add the foreign key constraint
    # This will prevent deletion of fungus_types that have associated mushrooms
    # and ensure mushrooms always reference valid fungus_types
    unless foreign_key_exists?(:mushrooms, :fungus_types)
      add_foreign_key :mushrooms, :fungus_types, on_delete: :restrict
    end
  end

  def down
    remove_foreign_key :mushrooms, :fungus_types if foreign_key_exists?(:mushrooms, :fungus_types)
  end
end
