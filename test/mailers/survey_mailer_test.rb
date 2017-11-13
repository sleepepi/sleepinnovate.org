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
    mail = SurveyMailer.surveys_available(users(:consented), events(:followup_3month))
    assert_equal "SleepINNOVATE 3-Month Follow-up Available", mail.subject
    assert_equal ["consented@example.com"], mail.to
    assert_equal ["travis-ci@example.com"], mail.from
    assert_match "Three months ago, you joined our innovative sleep research project.", mail.body.encoded
  end

  test "surveys reminder email" do
    mail = SurveyMailer.surveys_reminder(users(:consented), events(:followup_3month))
    assert_equal "Continue Your 3-Month Follow-up", mail.subject
    assert_equal ["consented@example.com"], mail.to
    assert_equal ["travis-ci@example.com"], mail.from
    assert_match "We noticed that you have not yet completed your brief surveys and brain quizzes.", mail.body.encoded
  end

  test "followup summary email" do
    mail = SurveyMailer.followup_summary(users(:admin), activations, reminders)
    assert_equal "Followup Summary for #{Time.zone.today.strftime("%a %d %b %Y")}", mail.subject
    assert_equal ["admin@example.com"], mail.to
    assert_equal ["travis-ci@example.com"], mail.from
    assert_match "Event activations and reminders for #{Time.zone.today.strftime("%A, %B %-d, %Y")}.", mail.body.encoded
    assert_match "6-Month Follow-up activated 184 days after consent", mail.body.encoded
    assert_match "3-Month Follow-up activated 92 days after consent", mail.body.encoded
    assert_match "3-Month Follow-up reminder 97 days after consent", mail.body.encoded
  end

  def activations
    [
      { subject: "INN00001", events: [{ event: "6-Month Follow-up", days_after_consent: 184 }] },
      { subject: "INN00003", events: [{ event: "3-Month Follow-up", days_after_consent: 92 }] }
    ]
  end

  def reminders
    [
      { subject: "INN00002", events: [{ event: "3-Month Follow-up", days_after_consent: 97 }] }
    ]
  end
end
