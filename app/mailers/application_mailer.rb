# frozen_string_literal: true

# Default mailer for application.
class ApplicationMailer < ActionMailer::Base
  default from: "#{ENV["website_name"]} <#{ActionMailer::Base.smtp_settings[:email]}>"
  helper EmailHelper
  layout "mailer"

  protected

  def setup_email
    # attachments.inline['innovate-logo.png'] = File.read('app/assets/images/innovate_logo_64.png') rescue nil
  end
end
