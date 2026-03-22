require "test_helper"

class MushroomSortingQueryTest < ActiveSupport::TestCase
  test "by_genus_and_color returns ordered relation" do
    relation = MushroomSortingQuery.by_genus_and_color(Mushroom.all)
    assert_kind_of ActiveRecord::Relation, relation

    # Execute to ensure SQL is valid
    assert relation.to_a.is_a?(Array)
  end
end
