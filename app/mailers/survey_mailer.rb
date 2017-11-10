# frozen_string_literal: true

# Sends out survey activation and reminder emails.
class SurveyMailer < ApplicationMailer
  def brain_quizzes_available(user)
    setup_email
    @user = user
    @token = token
    @email_to = user.email
    mail(to: @email_to, subject: "SleepINNOVATE Brain Quizzes Available")
  end

  def surveys_available(user)
    setup_email
    @user = user
    @token = token
    @event = event
    @email_to = user.email
    mail(to: @email_to, subject: "SleepINNOVATE #{@event.dig(:name)} Available")
  end

  def surveys_reminder(user)
    setup_email
    @user = user
    @token = token
    @event = event
    @email_to = user.email
    mail(to: @email_to, subject: "Continue Your #{@event.dig(:name)}")
  end

  private

  def token
    SecureRandom.hex(8)
  end

  def event
    {
      number: "three",
      name: "3-Month Follow-up",
      slug: "followup-3month"
    }
  end
end
