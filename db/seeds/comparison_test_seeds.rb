# frozen_string_literal: true

# ============================================================================
# COMPREHENSIVE COMPARISON TEST SEEDS
# ============================================================================
# Creates realistic test data for mushroom comparison feature at scale.
# Run with: rails runner db/seeds/comparison_test_seeds.rb
#
# This script creates:
# - 5 test users (casual, regular, and power users)
# - 50 total mushrooms with varying detail levels:
#   * 10 mushrooms with 10-15 characters (minimum viable)
#   * 20 mushrooms with 20-50 characters (typical use)
#   * 15 mushrooms with 50-150 characters (detailed entries)
#   * 5 mushrooms with 150-300+ characters (power user level)
# - Intentional similarity groups for testing
# - Mix of fungus types, locations, and characteristics
# ============================================================================

puts "🍄 Creating comprehensive comparison test data..."
puts "=" * 60

# Ensure we have required lookup data
unless Country.exists? && FungusType.exists? && MrCharacter.exists?
  puts "❌ Error: Required data missing. Please run main seeds first."
  exit 1
end

# Add timestamp for unique names
timestamp = Time.now.strftime("%Y%m%d_%H%M%S")

# Get all available data
countries = Country.limit(5).to_a
fungus_types = FungusType.all.to_a
all_characters = MrCharacter.includes(:display_option, :color).to_a

puts "📋 Available data:"
puts "   Countries: #{countries.count}"
puts "   Fungus types: #{fungus_types.count}"
puts "   MR Characters: #{all_characters.count}"
puts ""

if all_characters.size < 20
  puts "⚠️  Warning: Only #{all_characters.size} characters available."
  puts "   Comparisons will be limited. Consider adding more mr_characters."
end

# Create test users with different profiles
test_users = []
user_profiles = [
  { email: "casual_user@example.com", role: "Casual collector - minimal entries" },
  { email: "regular_user@example.com", role: "Regular user - moderate detail" },
  { email: "detail_user@example.com", role: "Detail-oriented user" },
  { email: "power_user@example.com", role: "Power user - extensive documentation" },
  { email: "expert_user@example.com", role: "Expert user - comprehensive records" }
]

user_profiles.each do |profile|
  user = User.find_or_create_by!(email: profile[:email]) do |u|
    u.password = "password123"
    u.password_confirmation = "password123"
    u.skip_confirmation! if u.respond_to?(:skip_confirmation!)
  end
  test_users << { user: user, profile: profile[:role] }
  puts "✓ Created #{profile[:role]}: #{user.email}"
end

puts ""
puts "🍄 Creating mushrooms with varying detail levels..."
puts ""

created_mushrooms = []

# Helper to generate character value
def generate_value(character)
  case character.display_option.name
  when /boolean|checkbox/i
    ["true", "false"].sample
  when /color/i
    character.color&.id.to_s if character.color
  when /number|integer/i
    rand(1..100).to_s
  when /text|string/i
    ["smooth", "rough", "scaly", "fibrous", "sticky", "dry"].sample
  else
    ["present", "absent", "variable", "typical", "atypical"].sample
  end
end

# Helper to add characters to mushroom
def add_characters(mushroom, character_pool, count)
  selected_chars = character_pool.sample(count)
  added = 0

  selected_chars.each do |character|
    value = generate_value(character)
    next if value.nil?

    begin
      MrCharacterMushroom.create!(
        mushroom: mushroom,
        mr_character: character,
        character_value: value
      )
      added += 1
    rescue => e
      # Skip if validation fails (e.g., duplicate character)
    end
  end

  added
end

# ============================================================================
# GROUP 1: Minimal entries (10-15 characters) - 10 mushrooms
# ============================================================================
puts "📝 Creating minimal detail mushrooms (10-15 characters)..."
10.times do |i|
  user_data = test_users[i % 2] # Casual and regular users

  mushroom = Mushroom.create!(
    name: "Test Mushroom #{i + 1} - Minimal (#{timestamp})",
    description: "Basic identification with minimal characteristics recorded",
    comments: "Quick field observation",
    user: user_data[:user],
    country: countries.sample,
    fungus_type: fungus_types.sample
  )

  char_count = add_characters(mushroom, all_characters, rand(10..15))
  created_mushrooms << mushroom
  puts "  ✓ #{mushroom.name} (#{char_count} characters)"
end

# ============================================================================
# GROUP 2: Typical entries (20-50 characters) - 20 mushrooms
# ============================================================================
puts ""
puts "📝 Creating typical detail mushrooms (20-50 characters)..."
20.times do |i|
  user_data = test_users[1 + (i % 3)] # Regular, detail, and power users

  mushroom = Mushroom.create!(
    name: "Test Mushroom #{i + 11} - Standard (#{timestamp})",
    description: "Standard documentation with typical field observations",
    comments: "Photographed and documented with common characteristics",
    user: user_data[:user],
    country: countries.sample,
    fungus_type: fungus_types.sample
  )

  char_count = add_characters(mushroom, all_characters, rand(20..50))
  created_mushrooms << mushroom
  puts "  ✓ #{mushroom.name} (#{char_count} characters)"
end

# ============================================================================
# GROUP 3: Detailed entries (50-150 characters) - 15 mushrooms
# ============================================================================
puts ""
puts "📝 Creating detailed mushrooms (50-150 characters)..."

# Create similarity groups for testing
similarity_groups = [
  { base_name: "Amanita", char_range: (0...100), count: 5 },
  { base_name: "Boletus", char_range: (50...150), count: 5 },
  { base_name: "Cantharellus", char_range: (25...125), count: 5 }
]

similarity_groups.each_with_index do |group, group_idx|
  group[:count].times do |i|
    user_data = test_users[2 + (i % 3)] # Detail, power, and expert users

    # Create variations within the group (high similarity)
    variation = ["var. A", "var. B", "specimen", "mature", "young"][i]

    mushroom = Mushroom.create!(
      name: "#{group[:base_name]} #{variation} #{group_idx + 1} (#{timestamp})",
      description: "Detailed documentation of #{group[:base_name]} characteristics",
      comments: "Comprehensive field and microscopic observations",
      user: user_data[:user],
      country: countries.sample,
      fungus_type: fungus_types.sample
    )

    # Use overlapping character ranges for similarity within group
    char_subset = all_characters[group[:char_range]] || all_characters
    char_count = add_characters(mushroom, char_subset, rand(50..150))
    created_mushrooms << mushroom
    puts "  ✓ #{mushroom.name} (#{char_count} characters)"
  end
end

# ============================================================================
# GROUP 4: Power user entries (150-300+ characters) - 5 mushrooms
# ============================================================================
puts ""
puts "📝 Creating power user mushrooms (150+ characters)..."
5.times do |i|
  user_data = test_users[3 + (i % 2)] # Power and expert users

  mushroom = Mushroom.create!(
    name: "Expert Documentation #{i + 1} - Complete (#{timestamp})",
    description: "Exhaustive documentation including macroscopic, microscopic, chemical, and molecular characteristics. Multiple specimens examined across different seasons and locations.",
    comments: "Complete scientific documentation with DNA sequencing, spore measurements, chemical tests, and ecological notes. Voucher specimen deposited in herbarium.",
    user: user_data[:user],
    country: countries.sample,
    fungus_type: fungus_types.sample
  )

  # Use all available characters for power users
  max_chars = [all_characters.count, 300].min
  char_count = add_characters(mushroom, all_characters, rand(150..max_chars))
  created_mushrooms << mushroom
  puts "  ✓ #{mushroom.name} (#{char_count} characters)"
end

# ============================================================================
# Summary Statistics
# ============================================================================
puts ""
puts "=" * 60
puts "📊 SUMMARY STATISTICS"
puts "=" * 60

total_characters = created_mushrooms.sum { |m| m.mr_character_mushrooms.count }
avg_characters = total_characters / created_mushrooms.count

char_counts = created_mushrooms.map { |m| m.mr_character_mushrooms.count }.sort
median = char_counts[char_counts.size / 2]

puts ""
puts "Users created:              #{test_users.count}"
puts "Mushrooms created:          #{created_mushrooms.count}"
puts "Total character entries:    #{total_characters}"
puts ""
puts "Characters per mushroom:"
puts "  Minimum:                  #{char_counts.first}"
puts "  Average:                  #{avg_characters}"
puts "  Median:                   #{median}"
puts "  Maximum:                  #{char_counts.last}"
puts ""

# Group by character count ranges
ranges = [
  [0, 15, "Minimal (0-15)"],
  [16, 30, "Basic (16-30)"],
  [31, 50, "Standard (31-50)"],
  [51, 100, "Detailed (51-100)"],
  [101, 200, "Comprehensive (101-200)"],
  [201, 999, "Expert (200+)"]
]

puts "Distribution by detail level:"
ranges.each do |min, max, label|
  count = created_mushrooms.count { |m| m.mr_character_mushrooms.count.between?(min, max) }
  puts "  #{label.ljust(25)} #{count} mushrooms"
end

puts ""
puts "=" * 60
puts "🚀 READY TO TEST COMPARISONS!"
puts "=" * 60
puts ""
puts "Quick Start:"
puts "  1. Login as any test user (password: password123)"
puts "  2. Go to 'Your Mushrooms'"
puts "  3. Click any mushroom with 10+ characters"
puts "  4. Click 'Compare' button in the menu"
puts "  5. Click 'Start Comparison'"
puts ""
puts "Recommended test scenarios:"
puts "  • Compare minimal vs. detailed mushrooms (low similarity)"
puts "  • Compare within similarity groups (high similarity)"
puts "  • Compare power user entries (stress test)"
puts "  • Compare across different users (cross-ownership)"
puts ""
puts "Test users:"
test_users.each do |user_data|
  mushroom_count = created_mushrooms.count { |m| m.user_id == user_data[:user].id }
  puts "  #{user_data[:user].email.ljust(30)} (#{mushroom_count} mushrooms)"
end
puts ""
