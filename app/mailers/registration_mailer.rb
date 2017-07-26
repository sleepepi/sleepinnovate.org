# frozen_string_literal: true

# Sends out registration welcome emails.
class RegistrationMailer < ApplicationMailer
  def welcome_email(user, token)
    setup_email
    @user = user
    @token = token
    @email_to = user.email
    mail(to: @email_to, subject: "#{ENV['website_name']} - Account Activation")
  end
end
