#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"
require "set"

ROOT = Pathname.new(__dir__).join("..", "..").expand_path
TEST_FILE = ROOT.join("test", "integration", "authorization_guardrails_test.rb")

unless TEST_FILE.exist?
  warn "Missing guardrails test file: #{TEST_FILE}"
  exit 1
end

test_contents = TEST_FILE.read

controllers_match = test_contents.match(/GUARDED_MUTATION_CONTROLLERS\s*=\s*%w\[(.*?)\]/m)
exceptions_match = test_contents.match(/GUARDED_MUTATION_CONTROLLER_EXCEPTIONS\s*=\s*\{(.*?)\}\.freeze/m)

unless controllers_match
  warn "Missing GUARDED_MUTATION_CONTROLLERS in #{TEST_FILE}"
  exit 1
end

guarded_controllers = controllers_match[1].split.map(&:strip).reject(&:empty?).to_set

exceptions = Set.new
if exceptions_match
  exceptions_match[1].scan(/"([^"]+)"\s*=>/).each do |(name)|
    exceptions.add(name)
  end
end

MUTATION_METHODS = %w[
  create
  update
  destroy
  bulk_update
  destroy_by_relation
  clone_characters
].freeze

IN_SCOPE_FILES = Set.new(%w[
  all_group_mushrooms_controller.rb
  cluster_mushrooms_controller.rb
  image_mushrooms_controller.rb
  mr_character_mushrooms_controller.rb
  mushroom_plants_controller.rb
  mushroom_projects_controller.rb
  mushroom_species_controller.rb
  mushroom_trees_controller.rb
  genus_mushrooms_controller.rb
  mushrooms_controller.rb
  mushroom_comparisons_controller.rb
].freeze)

def controller_class_name(path)
  base = path.basename.to_s
  name = base.sub("_controller.rb", "")
  name.split("_").map(&:capitalize).join + "Controller"
end

mutation_controllers = []

Dir.glob(ROOT.join("app", "controllers", "**", "*_controller.rb")).each do |path|
  next if path.include?("/admin/")
  next if path.include?("/users/")
  next if path.include?("/rails/")

  file = Pathname.new(path)
  base = file.basename.to_s

  next unless IN_SCOPE_FILES.include?(base)

  content = file.read
  next unless MUTATION_METHODS.any? { |method| content.match?(/^\s*def\s+#{Regexp.escape(method)}\b/) }

  mutation_controllers << controller_class_name(file)
end

missing = mutation_controllers.uniq.sort.reject do |name|
  guarded_controllers.include?(name) || exceptions.include?(name)
end

if missing.any?
  warn "Authorization guardrails missing coverage for:"
  missing.each { |name| warn "  - #{name}" }
  warn "Add to GUARDED_MUTATION_CONTROLLERS (and tests) or document in GUARDED_MUTATION_CONTROLLER_EXCEPTIONS."
  exit 1
end

puts "Authorization guardrails check passed."
