# frozen_string_literal: true

# Preview consent emails.
class ConsentMailerPreview < ActionMailer::Preview
  def consent_pdf_email
    ConsentMailer.consent_pdf_email(User.consented.first)
  end
end
