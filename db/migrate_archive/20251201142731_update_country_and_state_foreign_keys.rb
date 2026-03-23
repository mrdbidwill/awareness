class UpdateCountryAndStateForeignKeys < ActiveRecord::Migration[8.0]
  def up
    # Remove existing foreign keys
    remove_foreign_key :mushrooms, :countries if foreign_key_exists?(:mushrooms, :countries)
    remove_foreign_key :mushrooms, :states if foreign_key_exists?(:mushrooms, :states)

    # Re-add foreign keys with proper on_delete behavior
    # Country: nullify on delete (matches model's dependent: :nullify)
    # State: nullify on delete (state is optional, so this is safe)
    add_foreign_key :mushrooms, :countries, on_delete: :nullify
    add_foreign_key :mushrooms, :states, on_delete: :nullify
  end

  def down
    # Remove the updated foreign keys
    remove_foreign_key :mushrooms, :countries if foreign_key_exists?(:mushrooms, :countries)
    remove_foreign_key :mushrooms, :states if foreign_key_exists?(:mushrooms, :states)

    # Restore original foreign keys without on_delete action
    add_foreign_key :mushrooms, :countries
    add_foreign_key :mushrooms, :states
  end
end
