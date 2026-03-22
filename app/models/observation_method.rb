# frozen_string_literal: true

# app/models/observation_method.rb
class ObservationMethod < ApplicationRecord
  has_many :mr_characters
  has_many :lookup_items
  validates :name, presence: true, uniqueness: true
end
