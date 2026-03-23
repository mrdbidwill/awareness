# frozen_string_literal: true

class DropLegacyGraphTables < ActiveRecord::Migration[8.0]
  LEGACY_TABLES = %i[
    admin_todos
    all_group_mushrooms
    all_groups
    camera_makes
    camera_models
    cameras
    cluster_mushrooms
    clusters
    colors
    core_character_sequences
    countries
    display_options
    dna_sequences
    fungus_types
    genera
    genus_mushrooms
    image_mushrooms
    inaturalist_observation_fields
    lenses
    lookup_items
    mb_lists
    mr_character_mushroom_colors
    mr_character_mushrooms
    mr_characters
    mushroom_comparisons
    mushroom_plants
    mushroom_projects
    mushroom_species
    mushroom_trees
    mushrooms
    observation_methods
    parts
    plants
    projects
    role_permissions
    roles
    source_data
    source_data_types
    species
    states
    storage_locations
    trees
    user_roles
  ].freeze

  def up
    execute "SET FOREIGN_KEY_CHECKS = 0"

    LEGACY_TABLES.each do |table_name|
      drop_table table_name, if_exists: true
    end
  ensure
    execute "SET FOREIGN_KEY_CHECKS = 1"
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Legacy graph tables were removed permanently"
  end
end
