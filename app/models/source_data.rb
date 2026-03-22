# frozen_string_literal: true

# app/models/source_data.rb

class SourceData < ApplicationRecord
  self.table_name = 'source_data'

  has_paper_trail

  belongs_to :source_data_type
  belongs_to :user, optional: true
  has_many :mr_characters
  has_many :lookup_items
  validates :title, presence: true, uniqueness: true
end
