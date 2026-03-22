# frozen_string_literal: true

class FungusType < ApplicationRecord
  has_many :core_character_sequences, dependent: :destroy, strict_loading: false
  has_many :mushrooms, dependent: :restrict_with_error
  has_many :mr_characters, dependent: :nullify

  validates :name, presence: true, uniqueness: true

  # Before destroying, provide helpful error message about associated records
  before_destroy :check_for_mushrooms

  private

  def check_for_mushrooms
    if mushrooms.exists?
      errors.add(:base, "Cannot delete fungus type '#{name}' because it has #{mushrooms.count} associated mushroom(s). Please reassign those mushrooms to another fungus type first.")
      throw :abort
    end
  end
end
