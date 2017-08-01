# frozen_string_literal: true

require "test_helper"

# Tests consent emails.
class ConsentMailerTest < ActionMailer::TestCase
  test "consent pdfemail" do
    mail = ConsentMailer.consent_pdf_email(users(:consented))
    assert_equal "#{ENV['website_name']} - Signed Consent Form", mail.subject
    assert_equal ["consented@example.com"], mail.to
    assert_equal ["travis-ci@example.com"], mail.from
    assert_match "You have consented to be part of the SleepINNOVATE study.", mail.body.encoded
  end
end
