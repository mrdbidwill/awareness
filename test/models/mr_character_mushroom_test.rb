# test/models/mr_character_mushroom_test.rb
require "test_helper"

class MrCharacterMushroomTest < ActiveSupport::TestCase
  def setup
    @mushroom = mushrooms(:one)
    @mr_character = mr_characters(:one)
    @mr_character_mushroom = mr_character_mushrooms(:one)
  end

  test "should be valid with valid attributes" do
    assert @mr_character_mushroom.valid?
  end

  test "should require character_value" do
    mcm = MrCharacterMushroom.new(mr_character: @mr_character, mushroom: @mushroom)
    assert_not mcm.valid?
    assert_includes mcm.errors[:character_value], "Character value cannot be blank."
  end

  test "should belong to mr_character" do
    assert_respond_to @mr_character_mushroom, :mr_character
  end

  test "should belong to mushroom" do
    assert_respond_to @mr_character_mushroom, :mushroom
  end

  test "should increment counter_cache on mushroom" do
    mushroom = Mushroom.create!(
      name: "Test Mushroom",
      user: users(:one),
      country: countries(:one),
      fungus_type: fungus_types(:one),
      collection_date: Date.today
    )
    initial_count = mushroom.mr_character_mushrooms_count || 0

    MrCharacterMushroom.create!(
      mushroom: mushroom,
      mr_character: @mr_character,
      character_value: "test_value"
    )

    assert_equal initial_count + 1, mushroom.reload.mr_character_mushrooms_count
  end

  test "should have colors_for_mushroom scope" do
    assert_respond_to MrCharacterMushroom, :colors_for_mushroom
  end

  test "should have timestamps" do
    assert_not_nil @mr_character_mushroom.created_at
    assert_not_nil @mr_character_mushroom.updated_at
  end

  # Multicolor tests
  test "should have many mr_character_mushroom_colors" do
    assert_respond_to @mr_character_mushroom, :mr_character_mushroom_colors
  end

  test "should have many colors through mr_character_mushroom_colors" do
    assert_respond_to @mr_character_mushroom, :colors
  end

  test "color_character? should return true when display_option_id is 6" do
    @mr_character.update!(display_option: display_options(:color_picker))
    @mr_character_mushroom.reload
    assert @mr_character_mushroom.color_character?
  end

  test "color_character? should return false when display_option_id is not 6" do
    @mr_character.update!(display_option: display_options(:one))
    @mr_character_mushroom.reload
    assert_not @mr_character_mushroom.color_character?
  end

  test "color_ids= should create mr_character_mushroom_colors" do
    color_one = colors(:one)
    color_two = colors(:two)

    @mr_character_mushroom.color_ids = [color_one.id, color_two.id]
    @mr_character_mushroom.save!

    assert_equal 2, @mr_character_mushroom.mr_character_mushroom_colors.count
    assert_equal [color_one.id, color_two.id].sort, @mr_character_mushroom.colors.pluck(:id).sort
  end

  test "color_ids= should set display_order based on array position" do
    color_one = colors(:one)
    color_two = colors(:two)

    @mr_character_mushroom.color_ids = [color_two.id, color_one.id]
    @mr_character_mushroom.save!

    ordered_colors = @mr_character_mushroom.mr_character_mushroom_colors.ordered
    assert_equal color_two.id, ordered_colors.first.color_id
    assert_equal color_one.id, ordered_colors.second.color_id
  end

  test "color_ids= should replace existing colors" do
    color_one = colors(:one)
    color_two = colors(:two)

    @mr_character_mushroom.color_ids = [color_one.id]
    @mr_character_mushroom.save!
    assert_equal 1, @mr_character_mushroom.colors.count

    @mr_character_mushroom.color_ids = [color_two.id]
    @mr_character_mushroom.save!
    assert_equal 1, @mr_character_mushroom.colors.count
    assert_equal color_two.id, @mr_character_mushroom.colors.first.id
  end

  test "ordered_colors should return colors in display_order" do
    color_one = colors(:one)
    color_two = colors(:two)

    @mr_character_mushroom.color_ids = [color_two.id, color_one.id]
    @mr_character_mushroom.save!

    ordered = @mr_character_mushroom.ordered_colors
    assert_equal [color_two.id, color_one.id], ordered.pluck(:id)
  end

  test "should validate presence of colors for color_character" do
    @mr_character.update!(display_option: display_options(:color_picker))
    mcm = MrCharacterMushroom.new(
      mushroom: @mushroom,
      mr_character: @mr_character
    )

    assert_not mcm.valid?
    assert_includes mcm.errors[:base], "At least one color must be selected"
  end

  test "should not require character_value for color_character" do
    @mr_character.update!(display_option: display_options(:color_picker))
    mcm = MrCharacterMushroom.new(
      mushroom: @mushroom,
      mr_character: @mr_character,
      character_value: nil
    )
    mcm.color_ids = [colors(:one).id]

    assert mcm.valid?
  end

  test "primary_color should return first color" do
    @mr_character_mushroom.color_ids = [colors(:two).id, colors(:one).id]
    @mr_character_mushroom.save!

    primary = @mr_character_mushroom.primary_color
    assert_equal colors(:two).id, primary.id
  end

  test "secondary_colors should return colors after first" do
    @mr_character_mushroom.color_ids = [colors(:one).id, colors(:two).id]
    @mr_character_mushroom.save!

    secondary = @mr_character_mushroom.secondary_colors
    assert_equal 1, secondary.count
    assert_equal colors(:two).id, secondary.first.id
  end

  test "color_ids should return array of color IDs in order" do
    @mr_character_mushroom.color_ids = [colors(:two).id, colors(:one).id]
    @mr_character_mushroom.save!

    ids = @mr_character_mushroom.color_ids
    assert_equal [colors(:two).id, colors(:one).id], ids
  end
end
