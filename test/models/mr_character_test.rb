require "test_helper"
require "securerandom"

class MrCharacterTest < ActiveSupport::TestCase
  def setup
    # Eager load all associations to avoid strict loading violations
    @mr_character = MrCharacter.includes(:part, :observation_method, :display_option, :source_data)
                               .find(mr_characters(:one).id)
    @fungus_type_one = fungus_types(:one)
    @fungus_type_two = fungus_types(:two)
  end

  test "should be valid" do
    assert @mr_character.valid?
  end

  test "should belong to part, observation_method, display_option, and source_data" do
    assert_not_nil @mr_character.part
    assert_not_nil @mr_character.observation_method
    assert_not_nil @mr_character.display_option
    # assert_not_nil @mr_character.source_data
  end

  test "select_core_for_display falls back to global core when no sequence exists" do
    scoped_core = create_character(core: true, fungus_type: @fungus_type_one)
    universal_core = create_character(core: true, fungus_type: nil)
    non_core = create_character(core: false, fungus_type: @fungus_type_one)

    result = MrCharacter.select_core_for_display(
      [scoped_core, universal_core, non_core],
      fungus_type_id: @fungus_type_one.id
    )

    assert_equal [scoped_core.id, universal_core.id].sort, result.map(&:id).sort
  end

  test "select_core_for_display uses only sequenced characters for configured fungus type" do
    char_a = create_character(core: true, fungus_type: @fungus_type_one)
    char_b = create_character(core: true, fungus_type: nil)

    CoreCharacterSequence.create!(fungus_type: @fungus_type_one, mr_character: char_b, sequence: 1)

    result = MrCharacter.select_core_for_display([char_a, char_b], fungus_type_id: @fungus_type_one.id)

    assert_equal [char_b.id], result.map(&:id)
  end

  test "select_core_for_display returns empty for unconfigured fungus type once sequences are enabled" do
    universal_core = create_character(core: true, fungus_type: nil)
    configured_char = create_character(core: true, fungus_type: @fungus_type_one)
    CoreCharacterSequence.create!(fungus_type: @fungus_type_one, mr_character: configured_char, sequence: 1)

    result = MrCharacter.select_core_for_display([universal_core], fungus_type_id: @fungus_type_two.id)

    assert_empty result
  end

  private

  def create_character(core:, fungus_type:)
    character = MrCharacter.create!(
      name: "mr_char_test_#{SecureRandom.hex(4)}",
      part: parts(:one),
      observation_method: observation_methods(:one),
      display_option: display_options(:text),
      source_data: source_data(:one),
      fungus_type: fungus_type
    )
    character.core = core
    character.save!
    character
  end
end
