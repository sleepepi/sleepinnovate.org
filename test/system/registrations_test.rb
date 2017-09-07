# frozen_string_literal: true

require "application_system_test_case"

# System tests for registration process.
class RegistrationsTest < ApplicationSystemTestCase
  test "registering and consenting" do
    visit root_url
    screenshot("register-consent")
    click_on "get started"
    screenshot("register-consent")
    click_on "Read consent"
    assert_selector "h1", text: "Consent"
    page.execute_script("$(\"#read_consent\").click();")
    click_on "I Consent"
    assert_selector "div", text: "Create your account"
    fill_in "user[full_name]", with: "John Smith"
    fill_in "user[email]", with: "jsmith@example.com"
    screenshot("register-consent")
    click_on "Create Account"
    assert_equal "John Smith", User.last.full_name
    assert_equal "jsmith@example.com", User.last.email
    screenshot("register-consent")
    assert_equal true, User.last.consented?
    assert_selector "h1", text: "Complete Your Profile"
    select "Dec", from: "date_of_birth[month]"
    select "31", from: "date_of_birth[day]"
    select "1984", from: "date_of_birth[year]"
    fill_in "address", with: "123 Road Street\nCity, ST 12345"
    screenshot("register-consent")
    click_on "Finish enrollment"
    assert_equal "1984-12-31", User.last.date_of_birth
    assert_equal "123 Road Street City, ST 12345", User.last.address
    assert_selector "a", text: "Start survey"
    screenshot("register-consent")
  end

  test "registering and refusing" do
    visit root_url
    screenshot("register-refuse")
    click_on "get started"
    screenshot("register-refuse")
    click_on "Read consent"
    screenshot("register-refuse")
    page.accept_confirm "Click \"OK\" to exit enrollment process." do
      click_on "I Do Not Consent"
    end
    assert_selector "h2", text: "Refused to join Study"
    screenshot("register-refuse")
  end

  test "registering and skipping consent" do
    visit root_url
    screenshot("register-skip-consent")
    click_on "get started"
    screenshot("register-skip-consent")
    visit new_user_registration_url
    assert_selector "div", text: "Create your account"
    fill_in "user[full_name]", with: "John Smith"
    fill_in "user[email]", with: "jsmith@example.com"
    screenshot("register-skip-consent")
    click_on "Create Account"
    assert_equal "John Smith", User.last.full_name
    assert_equal "jsmith@example.com", User.last.email
    visit dashboard_url
    assert_equal false, User.last.consented?
    assert_selector "h2", text: "Consent to study"
    screenshot("register-skip-consent")
  end

  test "registering and skipping profile" do
    visit root_url
    screenshot("register-skip-profile")
    click_on "get started"
    screenshot("register-skip-profile")
    click_on "Read consent"
    assert_selector "h1", text: "Consent"
    page.execute_script("$(\"#read_consent\").click();")
    click_on "I Consent"
    assert_selector "div", text: "Create your account"
    fill_in "user[full_name]", with: "John Smith"
    fill_in "user[email]", with: "jsmith@example.com"
    screenshot("register-skip-profile")
    click_on "Create Account"
    assert_equal "John Smith", User.last.full_name
    assert_equal "jsmith@example.com", User.last.email
    screenshot("register-skip-profile")
    assert_equal true, User.last.consented?
    visit dashboard_url
    assert_equal false, User.last.profile_complete?
    assert_selector "h2", text: "Complete your profile"
    screenshot("register-skip-profile")
  end
end
