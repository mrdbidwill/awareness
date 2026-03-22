# frozen_string_literal: true

require "test_helper"

class MrCharacterMushroomColorTest < ActiveSupport::TestCase
  setup do
    @mushroom = mushrooms(:one)
    @mr_character = mr_characters(:one)
    @mr_character.update!(display_option: display_options(:color_picker))
    @mr_character_mushroom = MrCharacterMushroom.new(
      mushroom: @mushroom,
      mr_character: @mr_character
    )
    # Skip validation and save directly for test setup
    @mr_character_mushroom.save(validate: false)
    @color_one = colors(:one)
    @color_two = colors(:two)
  end

  test "should be valid with valid attributes" do
    mcmc = MrCharacterMushroomColor.new(
      mr_character_mushroom: @mr_character_mushroom,
      color: @color_one,
      display_order: 1
    )
    assert mcmc.valid?
  end

  test "should belong to mr_character_mushroom" do
    mcmc = MrCharacterMushroomColor.create!(
      mr_character_mushroom: @mr_character_mushroom,
      color: @color_one,
      display_order: 1
    )
    assert_equal @mr_character_mushroom, mcmc.mr_character_mushroom
  end

  test "should belong to color" do
    mcmc = MrCharacterMushroomColor.create!(
      mr_character_mushroom: @mr_character_mushroom,
      color: @color_one,
      display_order: 1
    )
    assert_equal @color_one, mcmc.color
  end

  test "should require display_order" do
    mcmc = MrCharacterMushroomColor.new(
      mr_character_mushroom: @mr_character_mushroom,
      color: @color_one,
      display_order: nil
    )
    assert_not mcmc.valid?
    assert mcmc.errors[:display_order].any?
  end

  test "should require display_order to be integer" do
    mcmc = MrCharacterMushroomColor.new(
      mr_character_mushroom: @mr_character_mushroom,
      color: @color_one,
      display_order: "not a number"
    )
    assert_not mcmc.valid?
    assert_includes mcmc.errors[:display_order], "is not a number"
  end

  test "should require display_order to be greater than 0" do
    mcmc = MrCharacterMushroomColor.new(
      mr_character_mushroom: @mr_character_mushroom,
      color: @color_one,
      display_order: 0
    )
    assert_not mcmc.valid?
    assert_includes mcmc.errors[:display_order], "must be greater than 0"
  end

  test "should enforce uniqueness of color_id per mr_character_mushroom" do
    MrCharacterMushroomColor.create!(
      mr_character_mushroom: @mr_character_mushroom,
      color: @color_one,
      display_order: 1
    )

    duplicate = MrCharacterMushroomColor.new(
      mr_character_mushroom: @mr_character_mushroom,
      color: @color_one,
      display_order: 2
    )
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:color_id], "already added to this character"
  end

  test "ordered scope should return colors in display_order" do
    mcmc2 = MrCharacterMushroomColor.create!(
      mr_character_mushroom: @mr_character_mushroom,
      color: @color_two,
      display_order: 2
    )
    mcmc1 = MrCharacterMushroomColor.create!(
      mr_character_mushroom: @mr_character_mushroom,
      color: @color_one,
      display_order: 1
    )

    ordered = @mr_character_mushroom.mr_character_mushroom_colors.ordered
    assert_equal [@color_one.id, @color_two.id], ordered.map(&:color_id)
  end

  test "primary scope should return first color" do
    mcmc1 = MrCharacterMushroomColor.create!(
      mr_character_mushroom: @mr_character_mushroom,
      color: @color_one,
      display_order: 1
    )
    MrCharacterMushroomColor.create!(
      mr_character_mushroom: @mr_character_mushroom,
      color: @color_two,
      display_order: 2
    )

    primary = @mr_character_mushroom.mr_character_mushroom_colors.primary
    assert_equal 1, primary.count
    assert_equal mcmc1.id, primary.first.id
  end

  test "secondary scope should return colors after first" do
    MrCharacterMushroomColor.create!(
      mr_character_mushroom: @mr_character_mushroom,
      color: @color_one,
      display_order: 1
    )
    mcmc2 = MrCharacterMushroomColor.create!(
      mr_character_mushroom: @mr_character_mushroom,
      color: @color_two,
      display_order: 2
    )

    secondary = @mr_character_mushroom.mr_character_mushroom_colors.secondary
    assert_equal 1, secondary.count
    assert_equal mcmc2.id, secondary.first.id
  end
end
