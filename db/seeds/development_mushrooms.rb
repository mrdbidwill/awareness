# Development seed data for testing pagination and search features
# Run with: rails runner db/seeds/development_mushrooms.rb

puts "Starting mushroom seed data generation..."

# Get necessary references
user = User.find_by(id: 1) || User.first
unless user
  puts "❌ Error: No users found. Please create a user first."
  exit
end

country = Country.includes(:states).first
unless country
  puts "❌ Error: No countries found. Please seed countries first."
  exit
end

states = country.states.to_a
if states.empty?
  puts "⚠️  Warning: No states found for #{country.name}. Using country only."
  state = nil
else
  state = states.sample
end

fungus_types = FungusType.all.to_a
if fungus_types.empty?
  puts "❌ Error: No fungus types found. Please seed fungus types first."
  exit
end

# Common mushroom genera and species for realistic names
genera_names = [
  "Agaricus", "Amanita", "Boletus", "Cantharellus", "Cortinarius",
  "Hygrocybe", "Inocybe", "Lactarius", "Leccinum", "Mycena",
  "Pleurotus", "Russula", "Suillus", "Tricholoma", "Pholiota",
  "Galerina", "Gymnopilus", "Hypholoma", "Psilocybe", "Stropharia"
]

species_names = [
  "campestris", "muscaria", "edulis", "cibarius", "violaceus",
  "conica", "rimosa", "deliciosus", "scabrum", "pura",
  "ostreatus", "emetica", "luteus", "equestre", "squarrosa",
  "marginata", "spectabilis", "fasciculare", "cubensis", "aeruginosa"
]

descriptions = [
  "Found growing in mixed forest with oak and pine trees",
  "Specimen collected in grassland meadow after rain",
  "Growing on dead wood, possibly old oak log",
  "Found in fairy ring formation in lawn area",
  "Solitary specimen found under conifer trees",
  "Growing in clusters on forest floor with leaf litter",
  "Found near stream bank in moist conditions",
  "Growing on wood chips in cultivated garden bed",
  "Found at base of large deciduous tree",
  "Growing among moss in shaded forest area"
]

puts "Creating test mushrooms for user ##{user.id}..."

created_count = 0
target_count = 50 # Will give us ~105 total mushrooms for good pagination testing

target_count.times do |i|
  # Create realistic mushroom name
  genus = genera_names.sample
  species = species_names.sample
  common_name = "#{genus} specimen #{i + 56}" # Start numbering after existing

  mushroom = Mushroom.new(
    user: user,
    name: common_name,
    description: descriptions.sample,
    comments: ["Cap diameter approximately #{rand(2..15)}cm",
               "Spore print color: #{['white', 'cream', 'brown', 'black', 'pink'].sample}",
               "Odor: #{['none', 'pleasant', 'earthy', 'strong', 'mild'].sample}"].sample,
    country: country,
    state: states.sample,
    fungus_type: fungus_types.sample,
    collection_date: rand(90).days.ago
  )

  if mushroom.save
    # Add genus and species
    genus_record = Genus.find_or_create_by(name: genus.downcase)
    species_record = Species.find_or_create_by(name: species)

    mushroom.genera << genus_record unless mushroom.genera.include?(genus_record)
    mushroom.species << species_record unless mushroom.species.include?(species_record)

    created_count += 1
    print "." if (created_count % 10).zero?
  else
    puts "\n⚠️  Failed to create mushroom: #{mushroom.errors.full_messages.join(', ')}"
  end
end

puts "\n✅ Successfully created #{created_count} test mushrooms!"
puts "📊 Total mushrooms in database: #{Mushroom.count}"
puts "📄 This will display across #{(Mushroom.count / 12.0).ceil} pages (12 per page)"
puts "\n💡 Test the features:"
puts "   - Visit /mushrooms to see pagination"
puts "   - Visit /mushroom_search to test search"
puts "   - Visit /mushrooms/[id]/edit to test character cloning"
