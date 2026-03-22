# frozen_string_literal: true

# app/models/display_option.rb
class DisplayOption < ApplicationRecord
  validates :name, presence: true, uniqueness: true
end
