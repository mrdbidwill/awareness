class AddCityAndCountyToMushrooms < ActiveRecord::Migration[8.0]
  def change
    add_column :mushrooms, :city, :string
    add_column :mushrooms, :county, :string
  end
end
