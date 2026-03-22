require "test_helper"

class NPlusOneTest < ActiveSupport::TestCase
  # This test suite identifies and prevents N+1 query problems
  # N+1 queries occur when you fetch a collection, then loop through
  # and fetch associated records for each item individually

  setup do
    # Enable query logging for these tests
    @original_log_level = ActiveRecord::Base.logger.level
    ActiveRecord::Base.logger.level = Logger::DEBUG
  end

  teardown do
    ActiveRecord::Base.logger.level = @original_log_level
  end

  # Helper method to count queries
  def count_queries(&block)
    queries = []
    counter = ->(name, started, finished, unique_id, payload) {
      unless payload[:name] == "SCHEMA" || payload[:sql].include?("SHOW")
        queries << payload[:sql]
      end
    }

    ActiveSupport::Notifications.subscribed(counter, "sql.active_record", &block)
    queries.count
  end

  test "mushroom index should not have N+1 queries for user association" do
    # Create test data
    user = users(:one)

    # First query to establish baseline
    baseline = count_queries do
      Mushroom.includes(:user).limit(5).each do |mushroom|
        mushroom.user.email
      end
    end

    # Second query with more records should have similar count
    extended = count_queries do
      Mushroom.includes(:user).limit(10).each do |mushroom|
        mushroom.user.email
      end
    end

    # The number of queries should not increase linearly with records
    assert extended <= baseline + 1, "N+1 query detected: #{baseline} vs #{extended} queries"
  end

  test "mushroom with images should eager load images" do
    mushroom = mushrooms(:one)

    # Without eager loading
    without_eager = count_queries do
      m = Mushroom.strict_loading(false).find(mushroom.id)
      m.image_mushrooms.each { |im| im.image_file.attached? }
    end

    # With eager loading
    with_eager = count_queries do
      m = Mushroom.includes(image_mushrooms: { image_file_attachment: :blob }).find(mushroom.id)
      m.image_mushrooms.each { |im| im.image_file.attached? }
    end

    # Only assert if mushroom has images (otherwise no N+1 to test)
    if mushroom.image_mushrooms.any?
      assert_operator with_eager, :<=, without_eager, "Eager loading should reduce queries (without: #{without_eager}, with: #{with_eager})"
    else
      assert_equal without_eager, with_eager, "No images so query counts should be equal"
    end
  end

  test "mushroom with genus and species should eager load associations" do
    # Without eager loading - will cause N+1
    without_eager = count_queries do
      Mushroom.limit(5).strict_loading(false).each do |m|
        m.genus_mushrooms.each { |gm| gm.genus.name }
        m.mushroom_species.each { |ms| ms.species.name }
      end
    end

    # With eager loading - should be much fewer queries
    with_eager = count_queries do
      Mushroom.includes(genus_mushrooms: :genus, mushroom_species: :species).limit(5).each do |m|
        m.genus_mushrooms.each { |gm| gm.genus.name }
        m.mushroom_species.each { |ms| ms.species.name }
      end
    end

    assert_operator with_eager, :<, without_eager, "Eager loading should reduce queries (without: #{without_eager}, with: #{with_eager})"
  end

  test "mushroom projects should eager load users" do
    user = users(:one)

    without_eager = count_queries do
      MushroomProject.limit(5).strict_loading(false).each do |mp|
        mp.mushroom.user.email
        mp.project.user.email
      end
    end

    with_eager = count_queries do
      MushroomProject.includes(mushroom: :user, project: :user).limit(5).each do |mp|
        mp.mushroom.user.email
        mp.project.user.email
      end
    end

    assert with_eager < without_eager, "Eager loading should reduce queries for mushroom projects"
  end

  # TODO: Add N+1 test for MrCharacterMushroom associations if lookup_item is added
  # MrCharacterMushroom current associations: [:mr_character, :mushroom, :mr_character_mushroom_colors, :colors]
  # Does not have lookup_item association - test cannot be implemented as written
  # If lookup_item association is added in future, test eager loading of:
  # - mr_character
  # - lookup_item
  # - mushroom

  test "all_groups index should not have N+1 for mushroom count" do
    user = users(:one)

    # This tests that counting mushrooms doesn't cause N+1
    query_count = count_queries do
      AllGroup.includes(:mushrooms).where(user: user).each do |group|
        group.mushrooms.count
      end
    end

    # Should be roughly constant regardless of number of groups
    assert query_count < 10, "Too many queries for all_groups index: #{query_count}"
  end

  test "clusters index should eager load mushroom associations" do
    user = users(:one)

    with_eager = count_queries do
      Cluster.includes(:cluster_mushrooms, :mushrooms).where(user: user).limit(5).each do |cluster|
        cluster.mushrooms.each { |m| m.name }
      end
    end

    # Should not scale with number of mushrooms per cluster
    assert with_eager < 15, "Cluster index has too many queries: #{with_eager}"
  end

  test "mushroom search should not cause N+1 for associations" do
    with_associations = count_queries do
      Mushroom.includes(:user, genus_mushrooms: :genus, mushroom_species: :species)
              .limit(10)
              .each do |m|
        m.user.email
        m.genus_mushrooms.map { |gm| gm.genus.name }
        m.mushroom_species.map { |ms| ms.species.name }
      end
    end

    # Search queries should remain efficient
    assert with_associations < 20, "Search query causing N+1: #{with_associations} queries"
  end

  test "image_mushrooms with camera equipment should eager load" do
    without_eager = count_queries do
      ImageMushroom.limit(5).strict_loading(false).each do |im|
        im.lens&.make
        im.camera_make&.name
        im.camera_model&.name
        im.part&.name
        im.mushroom.name
      end
    end

    with_eager = count_queries do
      ImageMushroom.includes(:lens, :camera_make, :camera_model, :part, :mushroom).limit(5).each do |im|
        im.lens&.make
        im.camera_make&.name
        im.camera_model&.name
        im.part&.name
        im.mushroom.name
      end
    end

    assert_operator with_eager, :<, without_eager, "Image mushrooms need eager loading (without: #{without_eager}, with: #{with_eager})"
  end

  # Skip: Article model does not have user association
  # test "article index should eager load user associations" do
  #   query_count = count_queries do
  #     Article.includes(:user).published.limit(10).each do |article|
  #       article.user&.email
  #     end
  #   end
  #
  #   assert query_count < 5, "Article index has N+1 queries: #{query_count}"
  # end

  test "source_data with type should be eager loaded" do
    without_eager = count_queries do
      SourceData.limit(10).strict_loading(false).each do |sd|
        sd.source_data_type.name
      end
    end

    with_eager = count_queries do
      SourceData.includes(:source_data_type).limit(10).each do |sd|
        sd.source_data_type.name
      end
    end

    assert with_eager < without_eager, "SourceData needs eager loading for type"
  end

  test "mushroom comparison should eager load related mushrooms" do
    query_count = count_queries do
      MushroomComparison.includes(:mushroom, :compared_mushroom)
                        .limit(5)
                        .each do |comp|
        comp.mushroom&.name
        comp.compared_mushroom&.name
        comp.similarity_score
      end
    end

    assert query_count < 10, "Mushroom comparisons have N+1: #{query_count}"
  end

  test "roles with permissions should eager load through join table" do
    without_eager = count_queries do
      Role.limit(5).strict_loading(false).each do |role|
        role.permissions.each { |p| p.name }
      end
    end

    with_eager = count_queries do
      Role.includes(:permissions).limit(5).each do |role|
        role.permissions.each { |p| p.name }
      end
    end

    assert with_eager < without_eager, "Roles need eager loading for permissions"
  end

  test "users with roles should eager load through join table" do
    without_eager = count_queries do
      User.limit(5).strict_loading(false).each do |user|
        user.roles.each { |r| r.name }
      end
    end

    with_eager = count_queries do
      User.includes(:roles).limit(5).each do |user|
        user.roles.each { |r| r.name }
      end
    end

    assert with_eager < without_eager, "Users need eager loading for roles"
  end
end
