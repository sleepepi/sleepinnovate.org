# frozen_string_literal: true

# Preview registration emails.
class RegistrationMailerPreview < ActionMailer::Preview
  def welcome_email
    RegistrationMailer.welcome_email(
      User.new(full_name: "Full Name", email: "full_name@example.com"),
      "password"
    )
  end
end
