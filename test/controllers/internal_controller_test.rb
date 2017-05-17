# frozen_string_literal: true

require "test_helper"

# Tests to assure internal pages are accessible for logged in users.
class InternalControllerTest < ActionDispatch::IntegrationTest
  test "should get dashboard" do
    # login(@regular_user)
    get dashboard_url
    assert_response :success
  end

  test "should get survey" do
    # login(@regular_user)
    get survey_url
    assert_response :success
  end

  test "should get thank you" do
    # login(@regular_user)
    get thank_you_url
    assert_response :success
  end
end
