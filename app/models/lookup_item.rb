 # app/models/lookup_item.rb
 # frozen_string_literal: true

 class LookupItem < ApplicationRecord
   has_paper_trail
   self.inheritance_column = :_type_disabled  # stop rails from using default type column STI

   belongs_to :source_data
   belongs_to :mr_character

   # Ensure the name and parent combination is unique
   validates :name, presence: true, uniqueness: { scope: :id }
   validates :mr_character_id, presence: true
   validates :source_data_id, presence: true

   # Delegate name of observation_method for convenience
   delegate :name, to: :observation_method, prefix: true, allow_nil: true

   scope :by_observation_method_name, ->(type_name) {
     joins(mr_character: :observation_method).where(observation_methods: { name: type_name })
   }

   # Scope for countries
   scope :countries, -> { joins(:mr_character).where(mr_characters: { name: 'countries' }) }


   # Implement a convenience method to get a more descriptive observation_method name via mr_character
   def full_type
     type_name = mr_character&.observation_method&.name
     type_name.present? ? "#{type_name}: #{name}" : name.to_s
   end

   def self.available_for_mushroom_creation
     # Adjust the type name as needed; now uses the through-join scope
     by_observation_method_name('SomeType').pluck(:name, :id)
   end
 end
