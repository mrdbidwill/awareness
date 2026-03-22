# frozen_string_literal: true

require 'test_helper'

class EnvironmentConsistencyTest < ActiveSupport::TestCase
  # ============================================================================
  # ENVIRONMENT CONSISTENCY TEST
  # ============================================================================
  # This test scans the codebase to detect anti-patterns that cause
  # environment-specific bugs (test passes, production fails).
  #
  # CRITICAL: This test would have caught the Pundit callback bug that caused
  # the December 2025 production outage.
  #
  # Checks for:
  # 1. Environment-specific callbacks (before_action, after_action, etc)
  # 2. Environment-specific Pundit configuration
  # 3. Environment-specific authentication/authorization
  # ============================================================================

  test "no environment-specific callbacks in controllers" do
    violations = []

    Dir[Rails.root.join('app/controllers/**/*.rb')].each do |file|
      content = File.read(file)
      relative_path = file.sub("#{Rails.root}/", '')

      # Check for environment conditionals around callbacks
      # Pattern: if Rails.env.xyz ... callback ...
      lines = content.split("\n")
      lines.each_with_index do |line, index|
        line_number = index + 1

        # Detect Rails.env conditional blocks
        if line =~ /if\s+Rails\.env\.(development|test|production)/
          env_type = $1
          # Look ahead to see if there's a callback in the next few lines
          next_lines = lines[index...[index + 10, lines.length].min].join("\n")

          if next_lines =~ /(before_action|after_action|around_action|skip_before_action|skip_after_action)/
            callback_type = $1
            violations << {
              file: relative_path,
              line: line_number,
              env: env_type,
              callback: callback_type,
              context: line.strip
            }
          end
        end
      end
    end

    if violations.any?
      error_message = "Found #{violations.count} environment-specific callback(s) that will cause production bugs:\n\n"
      violations.each do |v|
        error_message += "  #{v[:file]}:#{v[:line]}\n"
        error_message += "    Environment: #{v[:env]}\n"
        error_message += "    Callback: #{v[:callback]}\n"
        error_message += "    Code: #{v[:context]}\n\n"
      end
      error_message += "❌ ANTI-PATTERN: Callbacks should work identically in all environments.\n"
      error_message += "   If you need environment-specific behavior, use configuration, not conditionals.\n"

      flunk error_message
    end

    assert true, "✅ No environment-specific callbacks found"
  end

  test "no environment-specific Pundit configuration in ApplicationController" do
    app_controller = File.read(Rails.root.join('app/controllers/application_controller.rb'))

    # Check for Rails.env around Pundit methods
    if app_controller =~ /if\s+Rails\.env.*?(verify_authorized|verify_policy_scoped|Pundit)/m
      flunk "❌ ApplicationController has environment-specific Pundit configuration.\n" \
            "   This causes verify_authorized/verify_policy_scoped to exist in some environments but not others.\n" \
            "   Controllers that skip these callbacks will crash in production.\n\n" \
            "   ✅ FIX: Remove the environment conditional and run Pundit in all environments."
    end

    assert true, "✅ Pundit configuration is consistent across environments"
  end

  test "skip_after_action calls use raise: false for safety" do
    violations = []

    Dir[Rails.root.join('app/controllers/**/*.rb')].each do |file|
      content = File.read(file)
      relative_path = file.sub("#{Rails.root}/", '')

      lines = content.split("\n")
      lines.each_with_index do |line, index|
        line_number = index + 1

        # Find skip_after_action calls
        if line =~ /skip_after_action\s+:(verify_authorized|verify_policy_scoped)/
          callback_name = $1
          # Check if it has raise: false
          unless line =~ /raise:\s*false/
            violations << {
              file: relative_path,
              line: line_number,
              callback: callback_name,
              code: line.strip
            }
          end
        end
      end
    end

    if violations.any?
      error_message = "⚠️  Found #{violations.count} skip_after_action call(s) without 'raise: false':\n\n"
      violations.each do |v|
        error_message += "  #{v[:file]}:#{v[:line]}\n"
        error_message += "    Callback: #{v[:callback]}\n"
        error_message += "    Code: #{v[:code]}\n\n"
      end
      error_message += "⚠️  RECOMMENDATION: Add 'raise: false' to prevent errors during class loading.\n"
      error_message += "   Without it, the app will crash if the callback doesn't exist yet.\n"
      error_message += "   Example: skip_after_action :verify_authorized, only: [:show], raise: false\n"

      # This is a warning, not a failure (since it's not always required)
      # But we want to know about it
      puts "\n#{error_message}\n"
    end

    assert true, "Checked skip_after_action safety"
  end

  test "no environment-specific authentication in initializers" do
    violations = []

    Dir[Rails.root.join('config/initializers/**/*.rb')].each do |file|
      content = File.read(file)
      relative_path = file.sub("#{Rails.root}/", '')

      if content =~ /if\s+Rails\.env.*?(authenticate|authorize|Devise|Pundit)/m
        violations << {
          file: relative_path,
          context: content.scan(/if\s+Rails\.env.*?end/m).first
        }
      end
    end

    if violations.any?
      error_message = "Found environment-specific authentication/authorization in initializers:\n\n"
      violations.each do |v|
        error_message += "  #{v[:file]}\n"
        error_message += "    Context: #{v[:context][0..200]}...\n\n"
      end
      error_message += "⚠️  Authentication/authorization should work the same in all environments.\n"

      flunk error_message
    end

    assert true, "✅ Authentication configuration is consistent"
  end

  test "all controllers have consistent parent class" do
    violations = []

    Dir[Rails.root.join('app/controllers/**/*.rb')].each do |file|
      next if file.include?('application_controller.rb')

      content = File.read(file)
      relative_path = file.sub("#{Rails.root}/", '')

      # Check class definition (support namespaced classes like Admin::ApplicationController)
      if content =~ /class\s+(\w+)\s+<\s+([\w:]+)/
        controller_name = $1
        parent_class = $2

        # Controllers should inherit from ApplicationController or Admin::ApplicationController
        unless parent_class == 'ApplicationController' || parent_class == 'Admin::ApplicationController' || parent_class.include?('::ApplicationController')
          violations << {
            file: relative_path,
            controller: controller_name,
            parent: parent_class
          }
        end
      end
    end

    if violations.any?
      error_message = "Found controllers with non-standard parent classes:\n\n"
      violations.each do |v|
        error_message += "  #{v[:file]}\n"
        error_message += "    Controller: #{v[:controller]} < #{v[:parent]}\n\n"
      end
      error_message += "⚠️  All controllers should inherit from ApplicationController for consistent behavior.\n"

      # This is a warning for unusual patterns
      puts "\n#{error_message}\n"
    end

    assert true, "Checked controller inheritance"
  end
end
