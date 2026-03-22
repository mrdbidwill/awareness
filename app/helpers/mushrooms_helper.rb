# frozen_string_literal: true

module MushroomsHelper
  def display_option_key(character)
    (character.display_option&.name&.downcase.presence) || character.display_option_id.to_s
  end
end
