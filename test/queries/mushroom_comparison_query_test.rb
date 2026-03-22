require "test_helper"

class MushroomComparisonQueryTest < ActiveSupport::TestCase
  test "similar_to builds matching scope" do
    mushroom = mushrooms(:one)

    results = MushroomComparisonQuery.new(Mushroom.all)
                                     .similar_to(mushroom)
                                     .excluding(mushroom)
                                     .with_minimum_matches(1)
                                     .by_similarity
                                     .top(5)
                                     .results

    assert_kind_of ActiveRecord::Relation, results
    assert results.to_a.is_a?(Array)
  end

  test "excluding handles empty list" do
    mushroom = mushrooms(:one)

    results = MushroomComparisonQuery.new(Mushroom.all)
                                     .similar_to(mushroom)
                                     .excluding([])
                                     .results

    assert_kind_of ActiveRecord::Relation, results
  end
end
