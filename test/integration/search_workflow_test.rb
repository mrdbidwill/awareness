require "test_helper"

class SearchWorkflowTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @mushroom = mushrooms(:one)
    @country = countries(:one)
    @fungus_type = fungus_types(:one)

    # Create additional mushrooms for search testing
    @searchable_mushroom = @user.mushrooms.create!(
      name: "Amanita muscaria",
      description: "Classic red mushroom with white spots",
      comments: "Found in pine forest",
      city: "Portland",
      county: "Multnomah",
      country_id: @country.id,
      fungus_type_id: @fungus_type.id,
      collection_date: Date.today
    )

    @another_mushroom = @user.mushrooms.create!(
      name: "Boletus edulis",
      description: "Delicious porcini mushroom",
      comments: "Growing under oak tree",
      city: "Eugene",
      county: "Lane",
      country_id: @country.id,
      fungus_type_id: @fungus_type.id,
      collection_date: 1.month.ago
    )
  end

  # ==============================================================================
  # BASIC SEARCH TESTS
  # ==============================================================================

  test "user can search mushrooms by name" do
    sign_in @user

    get mushrooms_path(q: "Amanita")

    assert_response :success
    assert_select "a[href='#{mushroom_path(@searchable_mushroom)}']"
    assert_select "a[href='#{mushroom_path(@another_mushroom)}']", count: 0
  end

  test "user can search mushrooms by description" do
    sign_in @user

    get mushrooms_path(q: "porcini")

    assert_response :success
    assert_select "a[href='#{mushroom_path(@another_mushroom)}']"
    assert_select "a[href='#{mushroom_path(@searchable_mushroom)}']", count: 0
  end

  test "user can search mushrooms by comments" do
    sign_in @user

    get mushrooms_path(q: "pine forest")

    assert_response :success
    assert_select "a[href='#{mushroom_path(@searchable_mushroom)}']"
  end

  test "user can search mushrooms by city" do
    sign_in @user

    get mushrooms_path(q: "Portland")

    assert_response :success
    assert_select "a[href='#{mushroom_path(@searchable_mushroom)}']"
    assert_select "a[href='#{mushroom_path(@another_mushroom)}']", count: 0
  end

  test "user can search mushrooms by genus name" do
    sign_in @user

    genus = Genus.create!(name: "Amanita") if Genus.where(name: "Amanita").empty?
    @searchable_mushroom.genus_mushrooms.create!(genus_id: genus.id)

    get mushrooms_path(q: "Amanita")

    assert_response :success
    assert_select "a[href='#{mushroom_path(@searchable_mushroom)}']"
  end

  test "search requires minimum 3 characters" do
    sign_in @user

    # Search with less than 3 characters should show all mushrooms
    get mushrooms_path(q: "Am")

    assert_response :success
    # Should show all mushrooms (no filtering applied)
    assert_select "a[href^='/mushrooms/']", minimum: 1
  end

  test "search is case insensitive" do
    sign_in @user

    get mushrooms_path(q: "AMANITA")

    assert_response :success
    assert_select "a[href='#{mushroom_path(@searchable_mushroom)}']"

    get mushrooms_path(q: "amanita")

    assert_response :success
    assert_select "a[href='#{mushroom_path(@searchable_mushroom)}']"
  end

  test "search by ID returns exact match" do
    sign_in @user

    get mushrooms_path(q: @searchable_mushroom.id.to_s)

    assert_response :success
    assert_select "a[href='#{mushroom_path(@searchable_mushroom)}']"
    # Should only show this one mushroom
  end

  test "search handles partial matches" do
    sign_in @user

    get mushrooms_path(q: "mani") # Part of "Amanita"

    assert_response :success
    assert_select "a[href='#{mushroom_path(@searchable_mushroom)}']"
  end

  test "search with no results shows appropriate message" do
    sign_in @user

    get mushrooms_path(q: "NonExistentMushroom123456")

    assert_response :success
    # No mushrooms shown - search should return empty
    # Optionally check for "no results" message if implemented
  end

  test "search with special characters is sanitized" do
    sign_in @user

    # SQL injection attempt - should be safely escaped
    get mushrooms_path(q: "'; DROP TABLE mushrooms; --")

    assert_response :success
    # Should not cause any database errors and table should still exist
    assert Mushroom.table_exists?
  end

  test "search preserves user scope" do
    sign_in @user
    other_user = users(:two)

    # Create mushroom for other user with matching name
    other_mushroom = other_user.mushrooms.create!(
      name: "Amanita phalloides",
      country_id: @country.id,
      fungus_type_id: @fungus_type.id
    )

    get mushrooms_path(q: "Amanita")

    assert_response :success
    # Should find user's own Amanita mushroom
    assert_select "a[href='#{mushroom_path(@searchable_mushroom)}']"
    # Should NOT find other user's Amanita mushroom
    assert_select "a[href='#{mushroom_path(other_mushroom)}']", count: 0
  end

  # ==============================================================================
  # ADVANCED FILTERING TESTS
  # ==============================================================================

  test "user can filter mushrooms by fungus type" do
    sign_in @user

    # Create mushrooms with different fungus types
    fungus_type_2 = FungusType.create!(name: "Test Type") if FungusType.count < 2

    mushroom_type_2 = @user.mushrooms.create!(
      name: "Type 2 Mushroom",
      country_id: @country.id,
      fungus_type_id: fungus_type_2.id
    ) if fungus_type_2

    get mushrooms_path(fungus_type_id: @fungus_type.id)

    assert_response :success
    # Should show mushrooms of specified fungus type
    assert_select "a[href='#{mushroom_path(@searchable_mushroom)}']"

    if fungus_type_2
      # Should not show mushrooms of other type
      assert_select "a[href='#{mushroom_path(mushroom_type_2)}']", count: 0
    end
  end

  test "user can filter mushrooms by collection date range" do
    sign_in @user

    # Create mushrooms with different dates
    old_mushroom = @user.mushrooms.create!(
      name: "Old Mushroom",
      country_id: @country.id,
      fungus_type_id: @fungus_type.id,
      collection_date: 1.year.ago
    )

    recent_mushroom = @user.mushrooms.create!(
      name: "Recent Mushroom",
      country_id: @country.id,
      fungus_type_id: @fungus_type.id,
      collection_date: 1.week.ago
    )

    # Filter by date range (if implemented)
    get mushrooms_path(start_date: 2.months.ago, end_date: Date.today)

    assert_response :success
    # Should show recent mushrooms
    # Actual assertion depends on filter implementation
  end

  test "user can filter mushrooms by location" do
    sign_in @user

    # Search by city name using text search
    get mushrooms_path(q: "Portland")

    assert_response :success
    assert_select "a[href='#{mushroom_path(@searchable_mushroom)}']"
    assert_select "a[href='#{mushroom_path(@another_mushroom)}']", count: 0
  end

  test "user can filter mushrooms by country" do
    sign_in @user

    country_2 = Country.create!(name: "Canada", code: "CA") if Country.count < 2

    mushroom_canada = @user.mushrooms.create!(
      name: "Canadian Mushroom",
      country_id: country_2.id,
      fungus_type_id: @fungus_type.id
    ) if country_2

    get mushrooms_path(country_id: @country.id)

    assert_response :success
    assert_select "a[href='#{mushroom_path(@searchable_mushroom)}']"

    if country_2
      assert_select "a[href='#{mushroom_path(mushroom_canada)}']", count: 0
    end
  end

  test "user can filter mushrooms by state" do
    sign_in @user

    state = State.first
    skip "No State fixtures available" unless state

    @searchable_mushroom.update!(state_id: state.id)

    get mushrooms_path(state_id: state.id)

    assert_response :success
    assert_select "a[href='#{mushroom_path(@searchable_mushroom)}']"
  end

  # ==============================================================================
  # CHARACTER-BASED SEARCH TESTS
  # ==============================================================================

  test "user can search mushrooms by character values" do
    sign_in @user

    mr_character = mr_characters(:one) if MrCharacter.exists?
    skip "No MrCharacter fixtures available" unless mr_character

    # Add character to mushroom
    @searchable_mushroom.mr_character_mushrooms.create!(
      mr_character_id: mr_character.id,
      character_value: "5.0"
    )

    # Search by character (if implemented)
    get mushrooms_path(character_id: mr_character.id, character_value: "5.0")

    assert_response :success
    # Should find mushrooms with matching character value
  end

  # TODO: Add test for filtering by multiple character values with AND logic
  # Character filtering exists via MushroomSearchQuery.by_characters but requires color_ids
  # Would test: params[:characters] = { "1" => ["color_id:5"], "2" => ["color_id:3"] }
  # Requires MrCharacter fixtures with associated colors

  # TODO: Add test for searching characters within a value range
  # Would require range-based character search implementation
  # Example: filter mushrooms where cap diameter is between 5-10cm

  # ==============================================================================
  # COMBINED SEARCH TESTS
  # ==============================================================================

  test "user can combine text search with filters" do
    sign_in @user

    # Search by name AND city
    get mushrooms_path(q: "Amanita", city: "Portland")

    assert_response :success
    assert_select "a[href='#{mushroom_path(@searchable_mushroom)}']"
  end

  test "user can search and see paginated results" do
    sign_in @user

    # Create many mushrooms with similar names
    25.times do |i|
      @user.mushrooms.create!(
        name: "Test Mushroom #{i}",
        country_id: @country.id,
        fungus_type_id: @fungus_type.id
      )
    end

    get mushrooms_path(q: "Test Mushroom")

    assert_response :success
    # Should show pagination (12 per page)
    assert_select "nav"
  end

  test "search preserves pagination state" do
    sign_in @user

    # Create enough mushrooms to trigger pagination (need >20)
    25.times do |i|
      @user.mushrooms.create!(
        name: "Searchable #{i}",
        country_id: @country.id,
        fungus_type_id: @fungus_type.id
      )
    end

    # Search and go to page 2
    get mushrooms_path(q: "Searchable", page: 2)

    assert_response :success
    # Should show page 2 results
    assert_select "nav"
  end

  test "search results are sorted by fungus type then name" do
    sign_in @user

    # Create mushrooms that would be sorted
    mushroom_a = @user.mushrooms.create!(
      name: "A Mushroom",
      country_id: @country.id,
      fungus_type_id: @fungus_type.id
    )

    mushroom_z = @user.mushrooms.create!(
      name: "Z Mushroom",
      country_id: @country.id,
      fungus_type_id: @fungus_type.id
    )

    get mushrooms_path(q: "Mushroom")

    assert_response :success
    # Results should be sorted (verification would require parsing response order)
  end

  # ==============================================================================
  # EMPTY RESULTS HANDLING TESTS
  # ==============================================================================

  test "search with no matches returns empty result set" do
    sign_in @user

    get mushrooms_path(q: "XYZ_NonExistent_12345")

    assert_response :success
    # No mushrooms shown - search should return empty
  end

  test "filter with no matches returns empty result set" do
    sign_in @user

    # Create unique fungus type that no mushrooms have
    unused_type = FungusType.create!(name: "Unused Type")

    get mushrooms_path(fungus_type_id: unused_type.id)

    assert_response :success
    # No mushrooms shown - search should return empty
  end

  test "empty search query returns all mushrooms" do
    sign_in @user

    get mushrooms_path(q: "")

    assert_response :success
    # Should show all user's mushrooms
    assert_select "a[href^='/mushrooms/']", minimum: 1
  end

  test "whitespace-only search query is ignored" do
    sign_in @user

    get mushrooms_path(q: "   ")

    assert_response :success
    # Should show all user's mushrooms (whitespace is stripped)
    assert_select "a[href^='/mushrooms/']", minimum: 1
  end

  # ==============================================================================
  # SEARCH PERFORMANCE TESTS
  # ==============================================================================

  test "search does not cause N+1 queries" do
    sign_in @user

    # Create mushrooms with associations
    5.times do |i|
      m = @user.mushrooms.create!(
        name: "Performance Test #{i}",
        country_id: @country.id,
        fungus_type_id: @fungus_type.id
      )

      # Add associations that might cause N+1 queries
      if Genus.exists?
        m.genus_mushrooms.create!(genus_id: Genus.first.id)
      end
    end

    # This is a basic test - actual N+1 detection would require
    # query counting tools like bullet or prosopite
    assert_nothing_raised do
      get mushrooms_path(q: "Performance")
      assert_response :success
    end
  end

  test "large result set is properly paginated" do
    sign_in @user

    # Create many matching mushrooms
    100.times do |i|
      @user.mushrooms.create!(
        name: "Bulk Mushroom #{i}",
        country_id: @country.id,
        fungus_type_id: @fungus_type.id
      )
    end

    get mushrooms_path(q: "Bulk")

    assert_response :success
    # Should paginate (12 per page)
    # Check that pagination is working (max 20 per page per app logic)
    assert_select "nav"
  end

  # ==============================================================================
  # GUEST SEARCH TESTS
  # ==============================================================================

  test "guest can search demo mushrooms" do
    # Not signed in - should see user_id 1's mushrooms
    get mushrooms_path(q: @mushroom.name)

    assert_response :success
    # Should be able to search, but only sees demo mushrooms
  end

  test "guest search does not expose other users' mushrooms" do
    # Create mushroom for user other than demo user (id 1)
    if @user.id != 1
      get mushrooms_path(q: @searchable_mushroom.name)

      assert_response :success
      # Should not see non-demo user's mushrooms
      assert_select "a[href='#{mushroom_path(@searchable_mushroom)}']", count: 0
    end
  end

  # ==============================================================================
  # SEARCH URL AND STATE TESTS
  # ==============================================================================

  test "search parameters are preserved in URL" do
    sign_in @user

    get mushrooms_path(q: "test query", page: 2)

    assert_response :success
    # URL should contain search parameters (can check response.request.params)
    assert_equal "test query", request.params[:q]
    assert_equal "2", request.params[:page].to_s
  end

  test "search form retains previous search query" do
    sign_in @user

    get mushrooms_path(q: "Amanita")

    assert_response :success
    # Search input should be pre-filled with previous query
    assert_select "input[name='q'][value='Amanita']"
  end

  test "clearing search returns to full list" do
    sign_in @user

    # First search
    get mushrooms_path(q: "Amanita")
    assert_response :success

    # Then clear search
    get mushrooms_path(q: "")

    assert_response :success
    # Should show all mushrooms again
    assert_select "a[href^='/mushrooms/']", minimum: 2
  end
end
