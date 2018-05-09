# frozen_string_literal: true

# Sends out survey activation and reminder emails.
class SurveyMailer < ApplicationMailer
  def brain_quizzes_available(user)
    setup_email
    @user = user
    @email_to = user.email
    mail(to: @email_to, subject: "SleepINNOVATE Brain Quizzes Available")
  end

  def surveys_available(user, event)
    setup_email
    @user = user
    @event = event
    @email_to = user.email
    mail(to: @email_to, subject: "SleepINNOVATE #{@event.name} Available")
  end

  def surveys_reminder(user, event)
    setup_email
    @user = user
    @event = event
    @email_to = user.email
    mail(to: @email_to, subject: "Continue Your #{@event.name}")
  end

  def followup_summary(user, activations, reminders)
    setup_email
    @user = user
    @activations = activations
    @reminders = reminders
    @email_to = user.email
    mail(
      to: @email_to,
      subject: "Followup Summary for #{Time.zone.today.strftime("%a %d %b %Y")}"
    )
  end

  def followup_summary_failure(user)
    setup_email
    @user = user
    @email_to = user.email
    mail(
      to: @email_to,
      subject: "Followup Summary FAILURE for #{Time.zone.today.strftime("%a %d %b %Y")}"
    )
  end
end
