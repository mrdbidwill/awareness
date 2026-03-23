# frozen_string_literal: true

class Reference < ApplicationRecord
  validates :name, presence: true

  scope :recent_first, -> { order(publish_date: :desc, created_at: :desc) }
end
