# frozen_string_literal: true

# Default mailer for application.
class ApplicationMailer < ActionMailer::Base
  default from: "#{ENV['website_name']} <#{ActionMailer::Base.smtp_settings[:email]}>"
  layout "mailer"
end
