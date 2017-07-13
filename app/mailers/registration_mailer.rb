# frozen_string_literal: true

# Sends out registration welcome emails.
class RegistrationMailer < ApplicationMailer
  def welcome_email(user, pw)
    setup_email
    @user = user
    @pw = pw
    @email_to = user.email
    mail(to: @email_to, subject: "#{ENV['website_name']} - Account Activation")
  end
end
