# frozen_string_literal: true

require "test_helper"

# Tests survey activation and reminder emails.
class SurveyMailerTest < ActionMailer::TestCase
  test "brain quizzes available email" do
    mail = SurveyMailer.brain_quizzes_available(users(:consented))
    assert_equal "SleepINNOVATE Brain Quizzes Available", mail.subject
    assert_equal ["consented@example.com"], mail.to
    assert_equal ["travis-ci@example.com"], mail.from
    assert_match "We're excited to announce that our brain quizzes are now ready for you!", mail.body.encoded
  end

  test "surveys available email" do
    mail = SurveyMailer.surveys_available(users(:consented))
    assert_equal "SleepINNOVATE 3-Month Follow-up Available", mail.subject
    assert_equal ["consented@example.com"], mail.to
    assert_equal ["travis-ci@example.com"], mail.from
    assert_match "Three months ago, you joined our innovative sleep research project.", mail.body.encoded
  end

  test "surveys reminder email" do
    mail = SurveyMailer.surveys_reminder(users(:consented))
    assert_equal "Continue Your 3-Month Follow-up", mail.subject
    assert_equal ["consented@example.com"], mail.to
    assert_equal ["travis-ci@example.com"], mail.from
    assert_match "We noticed that you have not yet completed your brief surveys and brain quizzes.", mail.body.encoded
  end
end
