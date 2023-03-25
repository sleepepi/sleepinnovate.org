# frozen_string_literal: true

require "test_helper"

SimpleCov.command_name "test:integration"

# Tests to assure that user navigation is working as intended.
class NavigationTest < ActionDispatch::IntegrationTest
  fixtures :users

  def setup
    @valid = users(:consented)
    @deleted = users(:deleted)
  end

  test "should get root path" do
    get "/"
    assert_equal "/", path
  end

  # test "should get sign up page" do
  #   get new_user_registration_url
  #   assert_equal new_user_registration_path, path
  #   assert_response :success
  # end

  # test "should register new account" do
  #   post user_registration_url, params: {
  #     user: {
  #       full_name: "register account",
  #       email: "register@account.com",
  #       email_confirmation: "register@account.com"
  #     }
  #   }
  #   assert_redirected_to profile_complete_url
  # end

  test "should login valid user" do
    get new_user_session_url
    login(@valid)
    assert_equal dashboard_path, path
  end

  test "should not login deleted user" do
    get new_user_session_url
    login(@deleted)
    assert_equal new_user_session_path, path
  end
end
