# frozen_string_literal: true

# Preview survey activation and reminder emails.
class SurveyMailerPreview < ActionMailer::Preview
  def brain_quizzes_available
    user = User.consented.first
    SurveyMailer.brain_quizzes_available(user)
  end

  def surveys_available
    user = User.consented.first
    SurveyMailer.surveys_available(user, Event.find_by(slug: "followup-3month"))
  end

  def surveys_reminder
    user = User.consented.first
    SurveyMailer.surveys_reminder(user, Event.find_by(slug: "followup-3month"))
  end

  def followup_summary
    user = User.where(admin: true).first
    activations = [
      { subject: "INN00001", events: [{ event: "6-Month Follow-up", days_after_consent: 184 }] },
      { subject: "INN00003", events: [{ event: "3-Month Follow-up", days_after_consent: 92 }] }
    ]
    reminders = [
      { subject: "INN00002", events: [{ event: "3-Month Follow-up", days_after_consent: 97 }] }
    ]
    SurveyMailer.followup_summary(user, activations, reminders)
  end
end
