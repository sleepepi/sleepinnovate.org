# frozen_string_literal: true

require "test_helper"

# Tests to assure settings pages are accessible for logged in users.
class SettingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @regular_user = users(:one)
    @withdrawn_user = users(:withdrawn)
  end

  test "should get consents" do
    login(@regular_user)
    get settings_consents_url
    assert_response :success
  end

  test "should get leave study" do
    login(@regular_user)
    get settings_leave_study_url
    assert_response :success
  end

  test "should get password" do
    login(@regular_user)
    get settings_password_url
    assert_response :success
  end

  test "should get settings" do
    login(@regular_user)
    get settings_url
    assert_response :success
  end
end
