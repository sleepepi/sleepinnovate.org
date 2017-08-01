# frozen_string_literal: true

# Sends out consent confirmation with PDF attachment emails.
class ConsentMailer < ApplicationMailer
  def consent_pdf_email(user)
    setup_email
    attachments["SleepINNOVATE Consent.pdf"] = File.read(pdf_file(user)) rescue nil
    @user = user
    @email_to = user.email
    mail(to: @email_to, subject: "#{ENV['website_name']} - Signed Consent Form")
  end

  def pdf_file(user)
    Rails.root.join(User.generate_printed_pdf!(user))
  end
end
