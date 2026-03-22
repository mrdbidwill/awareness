require "test_helper"
require "ostruct"

class MushroomPdfServiceTest < ActiveSupport::TestCase
  test "generate returns a Prawn document" do
    pdf = MushroomPdfService.new([mushrooms(:one)]).generate
    assert_kind_of Prawn::Document, pdf
  end

  test "sanitize_for_pdf handles invalid encoding" do
    service = MushroomPdfService.new([])
    invalid = String.new("\xC3").force_encoding("UTF-8")

    sanitized = service.send(:sanitize_for_pdf, invalid)
    assert_kind_of String, sanitized
  end

  test "location_text combines location parts" do
    service = MushroomPdfService.new([])
    mushroom = OpenStruct.new(
      city: "Austin",
      county: "Travis",
      state: OpenStruct.new(name: "Texas"),
      country: OpenStruct.new(name: "USA")
    )

    assert_equal "Austin, Travis, Texas, USA", service.send(:location_text, mushroom)
  end

  test "format_character_value handles key display options" do
    service = MushroomPdfService.new([])

    color_option = OpenStruct.new(name: "color")
    color_character = OpenStruct.new(display_option: color_option)
    color = OpenStruct.new(latin_name: "Amanita", common_name: "Red")
    rc_color = OpenStruct.new(mr_character: color_character, character_value: nil, ordered_colors: [color])
    assert_match(/Amanita/, service.send(:format_character_value, rc_color))

    radio_option = OpenStruct.new(name: "radio")
    radio_character = OpenStruct.new(display_option: radio_option)
    lookup = lookup_items(:one)
    rc_radio = OpenStruct.new(mr_character: radio_character, character_value: lookup.id, ordered_colors: [])
    assert_equal lookup.name, service.send(:format_character_value, rc_radio)

    boolean_option = OpenStruct.new(name: "boolean_yes_no")
    boolean_character = OpenStruct.new(display_option: boolean_option)
    rc_bool = OpenStruct.new(mr_character: boolean_character, character_value: "true", ordered_colors: [])
    assert_equal "Yes", service.send(:format_character_value, rc_bool)

    default_option = OpenStruct.new(name: "text")
    default_character = OpenStruct.new(display_option: default_option)
    rc_default = OpenStruct.new(mr_character: default_character, character_value: "raw", ordered_colors: [])
    assert_equal "raw", service.send(:format_character_value, rc_default)
  end
end
