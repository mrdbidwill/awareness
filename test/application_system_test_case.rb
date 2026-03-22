# test/application_system_test_case.rb
require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # Use the Selenium driver with headless Chrome by default
  driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400]

  # Optionally, you can override the driver for individual tests as needed
  # driven_by ENV.fetch("CAPYBARA_DRIVER", "selenium").to_sym, using: :headless_chrome, screen_size: [1400, 1400]

  teardown do
    if failed? # Capture screenshots only if the test has failed
      take_screenshot
    end
  end

end
