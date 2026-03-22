

# frozen_string_literal: true

module MrCharactersHelper
  # Replace underscores and make readable
  def character_display_name(name)
    return "" if name.blank?
    name.tr("_", " ")
  end

  # Determine display option key
  def display_option_key(character)
    (character.display_option&.name&.downcase.presence) || character.display_option_id.to_s
  end

  # LookupItem options for radio/drop-down, returns [[label, value], ...]
  def lookup_options_for(character)
    LookupItem.where(mr_character_id: character.id).order(:name).pluck(:name, :id)
  end

  # Render an input for a given character based on its display option.
  def input_for_character(form:, character:, current_value: nil)
    key = display_option_key(character)

    case key
    when "color", "6"
      content_tag(:span, "Use color picker below", class: "text-xs text-gray-500")
    when "radio", "9"
      options = lookup_options_for(character)
      return content_tag(:span, "No options", class: "text-xs text-gray-500") if options.blank?

      content_tag(:div, class: "flex flex-col gap-1") do
        options.map do |label, value|
          id = "#{character.id}-#{value}"
          content_tag(:label, for: id, class: "inline-flex items-center gap-2") do
            form.radio_button(:character_value, value, id: id, checked: current_value.to_s == value.to_s) +
              content_tag(:span, label.to_s, class: "text-sm")
          end
        end.join.html_safe
      end
    when "drop-down", "10"
      options = lookup_options_for(character)
      return content_tag(:span, "No options", class: "text-xs text-gray-500") if options.blank?

      form.select(
        :character_value,
        options_for_select(options, current_value),
        { include_blank: "Select..." },
        class: "border rounded px-2 py-1 text-sm w-full max-w-xs"
      )
    when "text_box_number_mm", "text_box_number_um", "text_box_number", "2", "3", "4"
      form.number_field :character_value, step: "any", class: "border rounded px-2 py-1 text-sm w-full max-w-xs", value: current_value
    when "text_box_string", "5"
      form.text_field :character_value, class: "border rounded px-2 py-1 text-sm w-full max-w-xs", value: current_value
    when "taste", "7", "odor", "8"
      # Until you define strict vocabularies, use a text field (can later swap to lookup)
      form.text_field :character_value, class: "border rounded px-2 py-1 text-sm w-full max-w-xs", value: current_value, placeholder: key
    when "state", "11", "country", "12"
      # Already handled elsewhere in your app; show hint only
      content_tag(:span, "Handled in location inputs", class: "text-xs text-gray-500")
    else
      # Sensible fallback
      form.text_field :character_value, class: "border rounded px-2 py-1 text-sm w-full max-w-xs", value: current_value
    end
  end
end
