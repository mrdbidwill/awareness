require "application_system_test_case"
require "securerandom"

class CoreCharacterSequenceFlowTest < ApplicationSystemTestCase
  setup do
    @admin = users(:three)
    @owner = users(:one)
    @mushroom = mushrooms(:one)
    @part = parts(:one)
    @observation_method = observation_methods(:one)
    @display_option = display_options(:text)
    @source_data = source_data(:one)
    @fungus_type = FungusType.create!(name: "core_seq_type_#{SecureRandom.hex(4)}")
    @mushroom.update!(fungus_type: @fungus_type)
  end

  test "admin can save per-fungus core sequence" do
    sign_in @admin

    char_a = create_core_character("core_seq_admin_a_#{SecureRandom.hex(4)}")
    char_b = create_core_character("core_seq_admin_b_#{SecureRandom.hex(4)}")

    visit admin_core_character_sequences_path(fungus_type_id: @fungus_type.id)

    assert_text "Sequence Core Characters"
    fill_in "core_sequences_#{char_a.id}", with: "2"
    fill_in "core_sequences_#{char_b.id}", with: "1"

    click_button "Save Core Sequence"

    assert_text "Core character sequence saved."
    assert_equal [char_b.id, char_a.id],
                 CoreCharacterSequence.where(fungus_type: @fungus_type).order(:sequence).pluck(:mr_character_id)
  end

  test "core toggle opens sequential flow and save next follows configured order" do
    sign_in @owner

    char_a = create_core_character("core_seq_flow_a_#{SecureRandom.hex(4)}")
    char_b = create_core_character("core_seq_flow_b_#{SecureRandom.hex(4)}")

    CoreCharacterSequence.create!(fungus_type: @fungus_type, mr_character: char_b, sequence: 1)
    CoreCharacterSequence.create!(fungus_type: @fungus_type, mr_character: char_a, sequence: 2)

    visit edit_mushroom_path(@mushroom)

    within("#character-grid") do
      click_link "Core (Default)", match: :first
    end

    assert_current_path mushroom_core_character_entry_path(@mushroom), ignore_query: true
    assert_text char_b.name.tr("_", " ")

    fill_in "character_value", with: "first core value"
    click_button "Save Character"

    assert_text "Character saved."
    assert_text char_b.name.tr("_", " ")
    assert_equal "first core value",
                 MrCharacterMushroom.find_by(mushroom: @mushroom, mr_character: char_b)&.character_value

    click_button "Save & Next"

    assert_text char_a.name.tr("_", " ")
    click_link "Done"
    assert_current_path edit_mushroom_path(@mushroom, core_only: true)

    within("#character-grid") do
      click_link "Core (Default)", match: :first
    end

    click_link "Back"
    assert_text char_b.name.tr("_", " ")
  end

  private

  def create_core_character(name)
    MrCharacter.create!(
      name: name,
      part: @part,
      observation_method: @observation_method,
      display_option: @display_option,
      source_data: @source_data,
      fungus_type: @fungus_type,
      properties: { "core" => true }
    )
  end
end
