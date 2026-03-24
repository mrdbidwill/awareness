# frozen_string_literal: true

class ArticleSourceCitation < ApplicationRecord
  belongs_to :article
  belongs_to :source

  validates :page_locator, length: { maximum: 100 }, allow_blank: true

  scope :ordered, -> { order(:position, :id) }
end
