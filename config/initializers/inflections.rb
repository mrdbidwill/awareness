# frozen_string_literal: true

# config/initializers/inflections.rb
ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.irregular 'lens', 'lenses' # Tell Rails explicitly that the singular of "lenses" is "lens"
  inflect.irregular 'genus', 'genera'
end

