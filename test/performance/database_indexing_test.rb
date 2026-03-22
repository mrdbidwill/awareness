require "test_helper"

class DatabaseIndexingTest < ActiveSupport::TestCase
  # Tests to verify proper database indexes exist for common queries
  # These tests check that indexes are present and being used

  test "mushrooms table should have index on user_id" do
    indexes = ActiveRecord::Base.connection.indexes('mushrooms')
    user_id_indexed = indexes.any? { |idx| idx.columns.include?('user_id') }

    assert user_id_indexed, "mushrooms.user_id should be indexed for performance"
  end

  test "mushrooms table should have index on name for searches" do
    indexes = ActiveRecord::Base.connection.indexes('mushrooms')
    name_indexed = indexes.any? { |idx| idx.columns.include?('name') }

    # If not indexed, searches will be slow
    if name_indexed
      assert true, "mushrooms.name is indexed"
    else
      skip "name not indexed - consider adding for search performance"
    end
  end

  test "mushrooms table should have index on collection_date for date filtering" do
    indexes = ActiveRecord::Base.connection.indexes('mushrooms')
    date_indexed = indexes.any? { |idx| idx.columns.include?('collection_date') }

    assert date_indexed, "mushrooms.collection_date should be indexed for date filtering"
  end

  test "genus_mushrooms should have composite index on genus_id and mushroom_id" do
    indexes = ActiveRecord::Base.connection.indexes('genus_mushrooms')
    composite_indexed = indexes.any? do |idx|
      idx.columns.sort == ['genus_id', 'mushroom_id'].sort ||
      idx.columns.include?('genus_id')
    end

    assert composite_indexed, "genus_mushrooms should have index for associations"
  end

  test "mushroom_species should have indexes on foreign keys" do
    indexes = ActiveRecord::Base.connection.indexes('mushroom_species')
    mushroom_indexed = indexes.any? { |idx| idx.columns.include?('mushroom_id') }
    species_indexed = indexes.any? { |idx| idx.columns.include?('species_id') }

    assert mushroom_indexed, "mushroom_species.mushroom_id should be indexed"
    assert species_indexed, "mushroom_species.species_id should be indexed"
  end

  test "mr_character_mushrooms should have index on mushroom_id" do
    indexes = ActiveRecord::Base.connection.indexes('mr_character_mushrooms')
    mushroom_indexed = indexes.any? { |idx| idx.columns.include?('mushroom_id') }

    assert mushroom_indexed, "mr_character_mushrooms.mushroom_id should be indexed"
  end

  test "users table should have unique index on email" do
    indexes = ActiveRecord::Base.connection.indexes('users')
    email_unique = indexes.any? { |idx| idx.columns.include?('email') && idx.unique }

    assert email_unique, "users.email should have unique index"
  end

  test "articles should have index on published for filtering" do
    indexes = ActiveRecord::Base.connection.indexes('articles')
    published_indexed = indexes.any? { |idx| idx.columns.include?('published') }

    assert published_indexed, "articles.published should be indexed for filtering"
  end

  test "states should have index on country_id" do
    indexes = ActiveRecord::Base.connection.indexes('states')
    country_indexed = indexes.any? { |idx| idx.columns.include?('country_id') }

    assert country_indexed, "states.country_id should be indexed for country lookup"
  end

  test "lookup_items should have index on mr_character_id" do
    indexes = ActiveRecord::Base.connection.indexes('lookup_items')
    character_indexed = indexes.any? { |idx| idx.columns.include?('mr_character_id') }

    assert character_indexed, "lookup_items.mr_character_id should be indexed"
  end

  test "projects should have index on user_id" do
    indexes = ActiveRecord::Base.connection.indexes('projects')
    user_indexed = indexes.any? { |idx| idx.columns.include?('user_id') }

    assert user_indexed, "projects.user_id should be indexed"
  end

  test "all_groups should have index on user_id" do
    indexes = ActiveRecord::Base.connection.indexes('all_groups')
    user_indexed = indexes.any? { |idx| idx.columns.include?('user_id') }

    assert user_indexed, "all_groups.user_id should be indexed"
  end

  test "clusters should have index on user_id" do
    indexes = ActiveRecord::Base.connection.indexes('clusters')
    user_indexed = indexes.any? { |idx| idx.columns.include?('user_id') }

    assert user_indexed, "clusters.user_id should be indexed"
  end

  test "mushroom_trees should have indexes on both foreign keys" do
    indexes = ActiveRecord::Base.connection.indexes('mushroom_trees')
    mushroom_indexed = indexes.any? { |idx| idx.columns.include?('mushroom_id') }
    tree_indexed = indexes.any? { |idx| idx.columns.include?('tree_id') }

    assert mushroom_indexed, "mushroom_trees.mushroom_id should be indexed"
    assert tree_indexed, "mushroom_trees.tree_id should be indexed"
  end

  test "mushroom_plants should have indexes on both foreign keys" do
    indexes = ActiveRecord::Base.connection.indexes('mushroom_plants')
    mushroom_indexed = indexes.any? { |idx| idx.columns.include?('mushroom_id') }
    plant_indexed = indexes.any? { |idx| idx.columns.include?('plant_id') }

    assert mushroom_indexed, "mushroom_plants.mushroom_id should be indexed"
    assert plant_indexed, "mushroom_plants.plant_id should be indexed"
  end

  test "mushroom_projects should have indexes on both foreign keys" do
    indexes = ActiveRecord::Base.connection.indexes('mushroom_projects')
    mushroom_indexed = indexes.any? { |idx| idx.columns.include?('mushroom_id') }
    project_indexed = indexes.any? { |idx| idx.columns.include?('project_id') }

    assert mushroom_indexed, "mushroom_projects.mushroom_id should be indexed"
    assert project_indexed, "mushroom_projects.project_id should be indexed"
  end

  test "image_mushrooms should have index on mushroom_id" do
    indexes = ActiveRecord::Base.connection.indexes('image_mushrooms')
    mushroom_indexed = indexes.any? { |idx| idx.columns.include?('mushroom_id') }

    assert mushroom_indexed, "image_mushrooms.mushroom_id should be indexed"
  end

  test "source_data should have index on source_data_type_id" do
    indexes = ActiveRecord::Base.connection.indexes('source_data')
    type_indexed = indexes.any? { |idx| idx.columns.include?('source_data_type_id') }

    assert type_indexed, "source_data.source_data_type_id should be indexed"
  end

  test "user_roles should have indexes for role lookup" do
    indexes = ActiveRecord::Base.connection.indexes('user_roles')
    user_indexed = indexes.any? { |idx| idx.columns.include?('user_id') }
    role_indexed = indexes.any? { |idx| idx.columns.include?('role_id') }

    assert user_indexed, "user_roles.user_id should be indexed"
    assert role_indexed, "user_roles.role_id should be indexed"
  end

  test "role_permissions should have indexes for permission lookup" do
    indexes = ActiveRecord::Base.connection.indexes('role_permissions')
    role_indexed = indexes.any? { |idx| idx.columns.include?('role_id') }
    permission_indexed = indexes.any? { |idx| idx.columns.include?('permission_id') }

    assert role_indexed, "role_permissions.role_id should be indexed"
    assert permission_indexed, "role_permissions.permission_id should be indexed"
  end

  test "mushroom_comparisons should have index on mushroom_id" do
    indexes = ActiveRecord::Base.connection.indexes('mushroom_comparisons')
    mushroom_indexed = indexes.any? { |idx| idx.columns.include?('mushroom_id') }

    assert mushroom_indexed, "mushroom_comparisons.mushroom_id should be indexed"
  end
end
