# frozen_string_literal: true

require "test_helper"

# Tests registration emails.
class RegistrationMailerTest < ActionMailer::TestCase
  test "welcome email" do
    mail = RegistrationMailer.welcome_email(users(:one), "password")
    assert_equal "Welcome to #{ENV["website_name"]}", mail.subject
    assert_equal ["yellow_fish@example.com"], mail.to
    assert_equal ["travis-ci@example.com"], mail.from
    assert_match "Welcome to the SleepINNOVATE portal!", mail.body.encoded
  end
end
