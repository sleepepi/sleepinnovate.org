# frozen_string_literal: true

# Preview survey activation and reminder emails.
class SurveyMailerPreview < ActionMailer::Preview
  def brain_quizzes_available
    user = User.consented.first
    SurveyMailer.brain_quizzes_available(user)
  end

  def surveys_available
    user = User.consented.first
    SurveyMailer.surveys_available(user)
  end

  def surveys_reminder
    user = User.consented.first
    SurveyMailer.surveys_reminder(user)
  end
end
