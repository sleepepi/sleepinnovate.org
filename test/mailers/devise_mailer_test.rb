# frozen_string_literal: true

require "test_helper"

# Test devise emails.
class DeviseMailerTest < ActionMailer::TestCase
  test "reset password email" do
    user = users(:one)
    mail = Devise::Mailer.reset_password_instructions(user, "faketoken")
    assert_equal [user.email], mail.to
    assert_equal "Reset password instructions", mail.subject
    assert_match(%r{#{ENV["website_url"]}/password/edit\?reset_password_token=faketoken}, mail.body.encoded)
  end
end
