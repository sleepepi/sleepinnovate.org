# frozen_string_literal: true

require "test_helper"

# Tests to assure settings pages are accessible for logged in users.
class SettingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @regular_user = users(:one)
    @withdrawn_user = users(:withdrawn)
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

  test "should change password" do
    login(@regular_user)
    patch settings_change_password_url, params: {
      user: {
        current_password: "PASSword1",
        password: "NEWpassword2",
        password_confirmation: "NEWpassword2"
      }
    }
    assert_equal "Your password has been changed.", flash[:notice]
    assert_redirected_to settings_path
  end

  test "should not change password as user with invalid current password" do
    login(@regular_user)
    patch settings_change_password_url, params: {
      user: {
        current_password: "invalid",
        password: "NEWpassword2",
        password_confirmation: "NEWpassword2"
      }
    }
    assert_template "password"
    assert_response :success
  end

  test "should not change password with new password mismatch" do
    login(@regular_user)
    patch settings_change_password_url, params: {
      user: {
        current_password: "PASSword1",
        password: "NEWpassword2",
        password_confirmation: "mismatched"
      }
    }
    assert_template "password"
    assert_response :success
  end

  test "should not change password without meeting password requirements" do
    login(@regular_user)
    patch settings_change_password_url, params: {
      user: {
        current_password: "PASSword1",
        password: "newpassword",
        password_confirmation: "newpassword"
      }
    }
    assert_template "password"
    assert_response :success
  end
end
