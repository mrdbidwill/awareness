class AddStateCodeToStates < ActiveRecord::Migration[8.0]
  def change
    add_column :states, :state_code, :string
  end
end
