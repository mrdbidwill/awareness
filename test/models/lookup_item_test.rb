# test/models/lookup_item_test.rb
require "test_helper"

class LookupItemTest < ActiveSupport::TestCase
  def setup
    @lookup_item = lookup_items(:one)
  end

  test "should be valid with valid attributes" do
    assert @lookup_item.valid?
  end

  test "should require name" do
    lookup_item = LookupItem.new
    assert_not lookup_item.valid?
    assert_includes lookup_item.errors[:name], "Name cannot be blank."
  end

  test "should have paper_trail versioning" do
    assert_respond_to @lookup_item, :versions
  end

  test "should disable inheritance_column" do
    assert_equal :_type_disabled, LookupItem.inheritance_column.to_sym
  end

  test "should belong to source_data" do
    assert_respond_to @lookup_item, :source_data
  end

  test "should belong to mr_character" do
    assert_respond_to @lookup_item, :mr_character
  end

  test "should require mr_character_id" do
    lookup_item = LookupItem.new(name: "Test", source_data_id: SourceData.first.id)
    assert_not lookup_item.valid?
    assert_includes lookup_item.errors[:mr_character_id], "Mr character cannot be blank."
  end

  test "should require source_data_id" do
    lookup_item = LookupItem.new(name: "Test", mr_character_id: MrCharacter.first.id)
    assert_not lookup_item.valid?
    assert_includes lookup_item.errors[:source_data_id], "Source data cannot be blank."
  end

  test "should have by_observation_method_name scope" do
    assert_respond_to LookupItem, :by_observation_method_name
  end

  test "should have countries scope" do
    assert_respond_to LookupItem, :countries
  end

  test "should have full_type method" do
    assert_respond_to @lookup_item, :full_type
  end

  test "should have timestamps" do
    assert_not_nil @lookup_item.created_at
    assert_not_nil @lookup_item.updated_at
  end
end
