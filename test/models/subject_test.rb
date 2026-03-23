require "test_helper"

class SubjectTest < ActiveSupport::TestCase
  test "requires name" do
    subject = Subject.new

    assert_not subject.valid?
    assert subject.errors[:name].any?
  end

  test "generates slug from name when blank" do
    subject = Subject.new(name: "Forest Floor Ecology")

    assert subject.valid?
    assert_equal "forest-floor-ecology", subject.slug
  end

  test "normalizes provided slug" do
    subject = Subject.new(name: "Field Notes", slug: "Field Notes 2026")

    assert subject.valid?
    assert_equal "field-notes-2026", subject.slug
  end
end
