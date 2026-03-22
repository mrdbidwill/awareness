require "test_helper"

class MushroomComparisonTest < ActiveSupport::TestCase
  def setup
    @mushroom_one = mushrooms(:one)
    @mushroom_two = mushrooms(:two)
    @mushroom_three = mushrooms(:three)
    @comparison = mushroom_comparisons(:completed_high_similarity)
  end

  # === Validations ===

  test "should be valid with valid attributes" do
    assert @comparison.valid?
  end

  test "should require mushroom" do
    @comparison.mushroom = nil
    assert_not @comparison.valid?
    assert_includes @comparison.errors[:mushroom], "must exist"
  end

  test "should require compared_mushroom" do
    @comparison.compared_mushroom = nil
    assert_not @comparison.valid?
    assert_includes @comparison.errors[:compared_mushroom], "must exist"
  end

  test "should require similarity_score" do
    @comparison.similarity_score = nil
    assert_not @comparison.valid?
    assert @comparison.errors[:similarity_score].any?
  end

  test "should validate similarity_score is between 0 and 100" do
    @comparison.similarity_score = -1
    assert_not @comparison.valid?
    assert_includes @comparison.errors[:similarity_score], "must be greater than or equal to 0"

    @comparison.similarity_score = 101
    assert_not @comparison.valid?
    assert_includes @comparison.errors[:similarity_score], "must be less than or equal to 100"

    @comparison.similarity_score = 50
    assert @comparison.valid?
  end

  test "should require status" do
    @comparison.status = nil
    assert_not @comparison.valid?
    assert @comparison.errors[:status].any?
  end

  test "should validate status is one of pending, completed, or failed" do
    @comparison.status = "invalid_status"
    assert_not @comparison.valid?
    assert_includes @comparison.errors[:status], "is not included in the list"

    %w[pending completed failed].each do |status|
      @comparison.status = status
      assert @comparison.valid?, "#{status} should be a valid status"
    end
  end

  test "should not allow comparing a mushroom to itself" do
    comparison = MushroomComparison.new(
      mushroom: @mushroom_one,
      compared_mushroom: @mushroom_one,
      similarity_score: 100,
      matching_characters: 10,
      total_characters: 10,
      status: "completed"
    )
    assert_not comparison.valid?
    assert_includes comparison.errors[:compared_mushroom_id], "must be different from mushroom"
  end

  test "should enforce uniqueness of mushroom pair" do
    duplicate = MushroomComparison.new(
      mushroom: @comparison.mushroom,
      compared_mushroom: @comparison.compared_mushroom,
      similarity_score: 50,
      matching_characters: 5,
      total_characters: 10,
      status: "completed"
    )
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:compared_mushroom_id], "comparison already exists for this mushroom pair"
  end

  # === Associations ===

  test "should belong to mushroom" do
    assert_equal @mushroom_one, @comparison.mushroom
  end

  test "should belong to compared_mushroom" do
    assert_equal @mushroom_two, @comparison.compared_mushroom
  end

  # === Scopes ===

  test "completed scope returns only completed comparisons" do
    completed = MushroomComparison.completed
    assert_includes completed, mushroom_comparisons(:completed_high_similarity)
    assert_includes completed, mushroom_comparisons(:completed_low_similarity)
    assert_not_includes completed, mushroom_comparisons(:pending_comparison)
    assert_not_includes completed, mushroom_comparisons(:failed_comparison)
  end

  test "pending scope returns only pending comparisons" do
    pending = MushroomComparison.pending
    assert_includes pending, mushroom_comparisons(:pending_comparison)
    assert_not_includes pending, mushroom_comparisons(:completed_high_similarity)
  end

  test "failed scope returns only failed comparisons" do
    failed = MushroomComparison.failed
    assert_includes failed, mushroom_comparisons(:failed_comparison)
    assert_not_includes failed, mushroom_comparisons(:completed_high_similarity)
  end

  test "for_mushroom scope returns comparisons for specific mushroom" do
    comparisons = MushroomComparison.for_mushroom(@mushroom_one.id)
    assert_includes comparisons, mushroom_comparisons(:completed_high_similarity)
    assert_includes comparisons, mushroom_comparisons(:completed_low_similarity)
    assert_not_includes comparisons, mushroom_comparisons(:pending_comparison)
  end

  test "by_similarity scope orders by similarity score descending" do
    comparisons = MushroomComparison.for_mushroom(@mushroom_one.id).by_similarity
    scores = comparisons.pluck(:similarity_score)
    assert_equal scores.sort.reverse, scores
  end

  test "high_similarity scope returns comparisons above threshold" do
    high = MushroomComparison.high_similarity(50)
    assert_includes high, mushroom_comparisons(:completed_high_similarity)
    assert_not_includes high, mushroom_comparisons(:completed_low_similarity)
  end

  test "involving_mushroom scope returns comparisons in either direction" do
    # Mushroom two is primary in some, compared in others
    comparisons = MushroomComparison.involving_mushroom(@mushroom_two.id)
    assert_includes comparisons, mushroom_comparisons(:completed_high_similarity) # as compared
    assert_includes comparisons, mushroom_comparisons(:pending_comparison) # as primary
    assert_includes comparisons, mushroom_comparisons(:failed_comparison) # as primary
  end

  # === Instance Methods ===

  test "mark_completed! updates status and scores" do
    comparison = mushroom_comparisons(:pending_comparison)
    comparison.mark_completed!(75, 15, 20)

    comparison.reload
    assert_equal "completed", comparison.status
    assert_equal 75, comparison.similarity_score
    assert_equal 15, comparison.matching_characters
    assert_equal 20, comparison.total_characters
    assert_not_nil comparison.completed_at
  end

  test "mark_failed! updates status" do
    comparison = mushroom_comparisons(:pending_comparison)
    comparison.mark_failed!

    comparison.reload
    assert_equal "failed", comparison.status
    assert_not_nil comparison.completed_at
  end
end
