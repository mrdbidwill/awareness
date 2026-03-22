# frozen_string_literal: true

# app/models/part.rb
class Part < ApplicationRecord
  has_many :mr_characters
  validates :name, presence: true, uniqueness: true
end

