# test/support/factory_bot.rb
# FactoryBot configuration for test suite

FactoryBot.define do
  # Sequences for unique values
  sequence :email do |n|
    "user#{n}@example.com"
  end

  sequence :name do |n|
    "Name #{n}"
  end

  sequence :scientific_name do |n|
    "Species #{n}"
  end
end
