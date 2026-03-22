# frozen_string_literal: true

# Seed countries and states using carmen-rails
puts "Seeding countries and states..."

# Update existing countries with country codes if they exist
existing_mapping = {
  'USA' => 'US',
  'MEX' => 'MX',
  'CAN' => 'CA'
}

existing_mapping.each do |old_name, code|
  country = Country.find_by(name: old_name)
  if country && country.country_code.nil?
    country.update!(country_code: code)
    puts "✓ Updated existing #{old_name} with country_code #{code}"
  end
end

# Priority countries in desired order
priority_countries = [
  { code: 'US', name: 'United States' },
  { code: 'MX', name: 'Mexico' },
  { code: 'CA', name: 'Canada' }
]

# Seed priority countries first
priority_countries.each do |priority|
  carmen_country = Carmen::Country.coded(priority[:code])
  next unless carmen_country

  country = Country.find_or_initialize_by(country_code: carmen_country.code)
  country.name = carmen_country.name
  country.description ||= "Imported from carmen-rails"
  country.save!

  # Seed states/provinces for this country
  carmen_country.subregions.each do |subregion|
    state = State.find_or_initialize_by(
      country: country,
      state_code: subregion.code
    )
    state.name = subregion.name
    state.description ||= "Imported from carmen-rails"
    state.save!
  end

  puts "✓ Seeded #{country.name} with #{carmen_country.subregions.count} states/provinces"
end

# Seed remaining countries (alphabetically)
Carmen::Country.all.each do |carmen_country|
  # Skip priority countries we already seeded
  next if priority_countries.any? { |p| p[:code] == carmen_country.code }

  country = Country.find_or_initialize_by(country_code: carmen_country.code)
  country.name = carmen_country.name
  country.description ||= "Imported from carmen-rails"
  country.save!

  # Seed states/provinces for this country (if any)
  if carmen_country.subregions.any?
    carmen_country.subregions.each do |subregion|
      state = State.find_or_initialize_by(
        country: country,
        state_code: subregion.code
      )
      state.name = subregion.name
      state.description ||= "Imported from carmen-rails"
      state.save!
    end
  end
end

puts "Seeding complete!"
puts "Total countries: #{Country.count}"
puts "Total states/provinces: #{State.count}"
