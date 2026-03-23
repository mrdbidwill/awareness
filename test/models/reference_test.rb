require "test_helper"

class ReferenceTest < ActiveSupport::TestCase
  test "requires name" do
    reference = Reference.new(author: "Someone")
    assert_not reference.valid?
    assert reference.errors[:name].any?
  end
end
