# frozen_string_literal: true

require "application_system_test_case"

# System tests for internal pages.
class InternalTest < ApplicationSystemTestCase
  setup do
    @consented_user = users(:consented)
  end

  test "visit the dashboard" do
    password = "PASSword2"
    @consented_user.update(password: password, password_confirmation: password)
    complete_profile!(@consented_user)
    visit root_url
    click_on "Sign in", match: :first
    screenshot("visiting-dashboard")
    fill_in "user[email]", with: @consented_user.email
    fill_in "user[password]", with: @consented_user.password
    click_form_submit
    screenshot("visiting-dashboard")
    assert_selector "h4", text: "Baseline"
  end
end
