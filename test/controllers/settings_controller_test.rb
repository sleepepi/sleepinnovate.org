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

  test "should change email" do
    login(@regular_user)
    patch settings_change_email_url, params: {
      user: {
        current_password: "PASSword1",
        email: "yfish2@example.com",
        email_confirmation: "yfish2@example.com"
      }
    }
    assert_equal "Your email has been changed.", flash[:notice]
    assert_redirected_to settings_path
  end

  test "should not change email as user with invalid current password" do
    login(@regular_user)
    patch settings_change_email_url, params: {
      user: {
        current_password: "invalid",
        email: "yfish2@example.com",
        email_confirmation: "yfish2@example.com"
      }
    }
    assert_template "email"
    assert_response :success
  end

  test "should not change email with new email mismatch" do
    login(@regular_user)
    patch settings_change_email_url, params: {
      user: {
        current_password: "PASSword1",
        email: "yfish2@example.com",
        email_confirmation: "mismatched"
      }
    }
    assert_template "email"
    assert_response :success
  end

  test "should not change email without meeting email requirements" do
    login(@regular_user)
    patch settings_change_email_url, params: {
      user: {
        current_password: "PASSword1",
        email: "yfish2examplecom",
        email_confirmation: "yfish2examplecom"
      }
    }
    assert_template "email"
    assert_response :success
  end
end
