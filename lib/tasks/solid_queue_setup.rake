# frozen_string_literal: true

namespace :solid_queue do
  desc "Create Solid Queue tables in the queue database"
  task setup: :environment do
    ActiveRecord::Base.establish_connection(:queue)

    # Load and execute the queue schema
    load Rails.root.join("db/queue_schema.rb")

    puts "✓ Solid Queue tables created successfully"
  end
end
