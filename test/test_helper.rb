# test/test_helper.rb
ENV['RAILS_ENV'] ||= 'test'

# Code coverage tracking
require 'simplecov'
require 'simplecov-lcov'

SimpleCov::Formatter::LcovFormatter.config.report_with_single_file = true
SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::LcovFormatter
])

SimpleCov.start 'rails' do
  add_filter '/test/'
  add_filter '/config/'
  add_filter '/vendor/'
  add_filter %r{/.rbenv/} # Filter out gem code from rbenv
  add_group 'Controllers', 'app/controllers'
  add_group 'Models', 'app/models'
  add_group 'Helpers', 'app/helpers'
  add_group 'Mailers', 'app/mailers'
  add_group 'Jobs', 'app/jobs'
  add_group 'Policies', 'app/policies'
  add_group 'Services', 'app/services'

  # Enable branch coverage
  enable_coverage :branch

  # Start with lower target, will increase as we add tests
  minimum_coverage line: 50, branch: 40

  # Track coverage from last run to allow for normal code changes
  # Coverage drops are expected when removing code (like migrating to gems)
  track_files '{app,lib}/**/*.rb'
end

require_relative '../config/environment'
require 'rails/test_help'
require 'devise'

# Load all support files
Dir[Rails.root.join('test/support/**/*.rb')].sort.each { |file| require file }

class ActiveSupport::TestCase
  # Disable parallel testing temporarily due to DRb connection issues
  # Can be re-enabled after verifying test isolation
  # parallelize(workers: 2)

  include Pundit::Authorization # Include Pundit explicitly in tests
  include FactoryBot::Syntax::Methods # FactoryBot syntax
  include ActiveJob::TestHelper # ActiveJob test helpers for job assertions

  # Set up all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Include Devise test helpers
  include Devise::Test::IntegrationHelpers

  # Helper method to sign in users in tests
  def sign_in_as(user)
    sign_in user
  end
end

class ActiveSupport::TestCase
  # Ensure Users are loaded before all others
  self.fixtures :users, :all_groups, :clusters, :cluster_mushrooms, :mushrooms, :mushroom_species, :source_data
end


class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include Pundit::Authorization

  # Make Pundit's policy and policy_scope methods available to views in tests
  def policy(record)
    Pundit.policy(current_user, record)
  end

  def policy_scope(scope)
    Pundit.policy_scope(current_user, scope)
  end

  # You don't need to define sign_in as it's provided by Devise::Test::IntegrationHelpers
end
