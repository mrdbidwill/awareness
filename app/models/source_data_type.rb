# frozen_string_literal: true

# app/models/source_data_type.rb

class SourceDataType < ApplicationRecord
  has_many :mr_characters
  validates :name, presence: true, uniqueness: true
end
