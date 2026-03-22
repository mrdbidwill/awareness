FactoryBot.define do
  factory :inaturalist_observation_field do
    sequence(:inaturalist_id) { |n| n }
    sequence(:name) { |n| "Observation Field #{n}" }
    datatype { "text" }
    user_id { 123456 }
    description { "A sample observation field for testing" }
    allowed_values { "yes|no|maybe" }
    values_count { 10 }
    users_count { 5 }
    sequence(:uuid) { |n| SecureRandom.uuid }
  end
end
