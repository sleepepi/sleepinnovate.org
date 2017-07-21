# frozen_string_literal: true

require "test_helper"

# Tests to assure internal pages are accessible for logged in users.
class InternalControllerTest < ActionDispatch::IntegrationTest
  setup do
    @regular_user = users(:one)
    @withdrawn_user = users(:withdrawn)
  end

  test "should get awards for regular user" do
    login(@regular_user)
    get awards_url
    assert_response :success
  end

  test "should get biobank for regular user" do
    login(@regular_user)
    get biobank_url
    assert_response :success
  end

  test "should get dashboard for regular user" do
    login(@regular_user)
    get dashboard_url
    assert_response :success
  end

  test "should get dashboard for withdrawn user" do
    login(@withdrawn_user)
    get dashboard_url
    assert_response :success
  end

  test "should get survey" do
    login(@regular_user)
    get survey_url
    assert_response :success
  end

  test "should get thank you" do
    login(@regular_user)
    get thank_you_url
    assert_response :success
  end

  test "should get test my brain for regular user" do
    login(@regular_user)
    get test_my_brain_url
    assert_response :success
  end
end
