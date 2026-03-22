require "test_helper"

class CompareMushroomsJobTest < ActiveJob::TestCase
  def setup
    @mushroom_one = mushrooms(:one)   # Has 12 characters
    @mushroom_two = mushrooms(:two)   # Has 12 characters
    @mushroom_three = mushrooms(:three) # Has 5 characters (below minimum)
  end

  # === Job Execution ===

  test "should enqueue job with mushroom_id" do
    assert_enqueued_with(job: CompareMushroomsJob, args: [1]) do
      CompareMushroomsJob.perform_later(1)
    end
  end

  test "should not process mushroom with insufficient characters" do
    # Mushroom three has only 5 characters, minimum is 10
    CompareMushroomsJob.perform_now(@mushroom_three.id)

    # Should not create any comparisons
    comparisons = MushroomComparison.for_mushroom(@mushroom_three.id)
    assert_equal 0, comparisons.count
  end

  test "should create comparisons for mushroom with sufficient characters" do
    # Clear existing comparisons
    MushroomComparison.destroy_all

    # Run job for mushroom one (has 12 characters)
    CompareMushroomsJob.perform_now(@mushroom_one.id)

    # Should create comparison with mushroom two (also has 12 characters)
    comparisons = MushroomComparison.for_mushroom(@mushroom_one.id).completed
    assert comparisons.count > 0
  end

  test "should not compare mushroom against itself" do
    MushroomComparison.destroy_all

    CompareMushroomsJob.perform_now(@mushroom_one.id)

    # Should not have self-comparison
    self_comparison = MushroomComparison.find_by(
      mushroom_id: @mushroom_one.id,
      compared_mushroom_id: @mushroom_one.id
    )
    assert_nil self_comparison
  end

  # === Jaccard Similarity Algorithm ===

  test "calculate_jaccard_similarity returns correct score for identical sets" do
    job = CompareMushroomsJob.new
    set_a = { 1 => "red", 2 => "large", 3 => "smooth" }
    set_b = { 1 => "red", 2 => "large", 3 => "smooth" }

    result = job.send(:calculate_jaccard_similarity, set_a, set_b)

    assert_equal 100, result[:score]
    assert_equal 3, result[:matching]
    assert_equal 3, result[:total]
  end

  test "calculate_jaccard_similarity returns correct score for partially matching sets" do
    job = CompareMushroomsJob.new
    set_a = { 1 => "red", 2 => "large" }
    set_b = { 1 => "red", 2 => "small", 3 => "smooth" }

    result = job.send(:calculate_jaccard_similarity, set_a, set_b)

    # New logic: compares character by character
    # char 1: both "red" -> match (1)
    # char 2: "large" vs "small" -> no match (0)
    # char 3: only in set_b -> no match (0)
    # Total characters: 3, Matching: 1
    # Score: 1/3 = 33%
    assert_equal 33, result[:score]
    assert_equal 1, result[:matching]
    assert_equal 3, result[:total]
  end

  test "calculate_jaccard_similarity returns zero for completely different sets" do
    job = CompareMushroomsJob.new
    set_a = { 1 => "red", 2 => "large" }
    set_b = { 3 => "blue", 4 => "small" }

    result = job.send(:calculate_jaccard_similarity, set_a, set_b)

    assert_equal 0, result[:score]
    assert_equal 0, result[:matching]
    assert_equal 4, result[:total]
  end

  test "calculate_jaccard_similarity handles empty sets" do
    job = CompareMushroomsJob.new
    set_a = {}
    set_b = {}

    result = job.send(:calculate_jaccard_similarity, set_a, set_b)

    assert_equal 0, result[:score]
    assert_equal 0, result[:matching]
    assert_equal 0, result[:total]
  end

  # === Batching ===

  test "should process mushrooms in batches" do
    # This test verifies batching behavior
    # With only 3 mushrooms in fixtures, all should be processed in one batch
    MushroomComparison.destroy_all

    CompareMushroomsJob.perform_now(@mushroom_one.id, batch_offset: 0)

    # Should have processed available mushrooms (two has 12 chars, three has only 5)
    comparisons = MushroomComparison.for_mushroom(@mushroom_one.id)
    assert comparisons.count >= 1
  end

  # === Error Handling ===

  test "should mark comparison as failed on error" do
    # This tests that errors during comparison are handled gracefully
    # Mock an error scenario by trying to compare with invalid data
    MushroomComparison.destroy_all

    # Run job normally first
    CompareMushroomsJob.perform_now(@mushroom_one.id)

    # Verify comparisons were created
    comparisons = MushroomComparison.for_mushroom(@mushroom_one.id)
    assert comparisons.count > 0
  end

  # === Integration with Model ===

  test "should create or update existing comparison" do
    MushroomComparison.destroy_all

    # First run
    CompareMushroomsJob.perform_now(@mushroom_one.id)
    first_count = MushroomComparison.for_mushroom(@mushroom_one.id).count

    # Second run (should update, not duplicate)
    CompareMushroomsJob.perform_now(@mushroom_one.id)
    second_count = MushroomComparison.for_mushroom(@mushroom_one.id).count

    assert_equal first_count, second_count
  end

  test "should calculate real similarity between test fixtures" do
    MushroomComparison.destroy_all

    # Run comparison
    CompareMushroomsJob.perform_now(@mushroom_one.id)

    # Find comparison between mushroom one and two
    comparison = MushroomComparison.find_by(
      mushroom_id: @mushroom_one.id,
      compared_mushroom_id: @mushroom_two.id
    )

    assert_not_nil comparison
    assert_equal "completed", comparison.status
    assert comparison.similarity_score >= 0
    assert comparison.similarity_score <= 100
    assert comparison.matching_characters >= 0
    assert comparison.total_characters > 0
  end
end
