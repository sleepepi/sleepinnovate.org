# frozen_string_literal: true

# Sends out consent confirmation email.
class ConsentMailer < ApplicationMailer
  def consent_pdf_email(user)
    setup_email
    @user = user
    @email_to = user.email
    mail(to: @email_to, subject: "#{ENV["website_name"]} Consent")
  end
end
