# app/models/state.rb
class State < ApplicationRecord
  belongs_to :country, class_name: "Country", foreign_key: :country_id
  has_many :mushrooms, dependent: :nullify

  # Validate state_code only for new records with carmen integration
  validates :state_code, presence: true, on: :create, if: -> { country&.country_code.present? }

  before_create :set_default_country
  before_destroy :check_for_mushrooms

  def self.fetch_by_id(id)
    find_by(id: id) || "N/A" # Returns 'N/A' if the record isn't found
  end

  # Safely access the `name` field
  def safe_name
    name.presence || "N/A"
  end

  # Get carmen subregion data
  def carmen_subregion
    return nil unless country&.country_code.present? && state_code.present?

    carmen_country = Carmen::Country.coded(country.country_code)
    @carmen_subregion ||= carmen_country&.subregions&.coded(state_code)
  end

  private

  def set_default_country
    # If the state's country is not set, and the associated `mr_character_id` is 101, set default country_id to 835
    if country_id.nil? && country&.mr_character_id == 101
      self.country_id = 1   # USA
    end
  end

  def check_for_mushrooms
    mushroom_count = mushrooms.count
    if mushroom_count > 0
      Rails.logger.warn("Deleting state '#{name}' with #{mushroom_count} associated mushroom(s). These records will have their state_id set to NULL.")
    end
  end

end

