# frozen_string_literal: true

require "test_helper"

# Set up ApplicationSystemTestCase system tests.
class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # Download chrome driver here: https://sites.google.com/a/chromium.org/chromedriver/downloads
  driven_by :selenium, using: :chrome, screen_size: [1400, 1400]

  setup do
    @screenshots_enabled = true
    @counter = 0
  end

  def screenshot(file_name)
    return unless @screenshots_enabled
    @counter += 1
    relative_location = File.join(
      "docs",
      SleepInnovate::VERSION::STRING,
      "screenshots",
      "#{file_name}-#{format("%02d", @counter)}.png"
    )
    page.save_screenshot(Rails.root.join(relative_location))
    # puts "[Screenshot]: #{relative_location}"
  end

  def click_form_submit
    find("input[type=submit]").click
  end

  def click_element(selector)
    page.execute_script("$(\"#{selector}\").click();")
  end

  def scroll_down
    page.execute_script("window.scrollBy(0, $(window).height());")
  end

  def complete_profile!(user)
    user.update(date_of_birth: "1984-12-31", address: "123 Road Way, City, ST 12345")
    user.save_signature!(IO.readlines(File.join("test", "support", "signatures", "data_uri.txt")).first)
  end
end
