# frozen_string_literal: true

require "application_system_test_case"

# System tests for internal pages.
class InternalTest < ApplicationSystemTestCase
  test "visiting the dashboard" do
    visit dashboard_path
    assert_selector "h1", text: "Dashboard"
    take_screenshot
  end
end
