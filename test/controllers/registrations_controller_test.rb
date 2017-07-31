# frozen_string_literal: true

require "test_helper"

# Tests to assure users can register on the site.
class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @regular_user = users(:one)
  end

  def user_params
    {
      full_name: "Full Name",
      email: "full_name@example.com"
    }
  end

  test "should sign up new user" do
    assert_difference("User.count") do
      post user_registration_path(user: user_params)
    end
    assert_equal I18n.t("devise.registrations.signed_up"), flash[:notice]
    assert_redirected_to consent_path
  end
end