# frozen_string_literal: true

# Adds a recaptcha on registration.
class RegistrationsController < Devise::RegistrationsController
  prepend_before_action :check_captcha, only: [:create]
  prepend_before_action :generate_password, only: [:create]
  append_after_action :generate_welcome_email, only: [:create]

  layout "full_page"

  private

  def check_captcha
    return unless RECAPTCHA_ENABLED && !verify_recaptcha
    self.resource = resource_class.new sign_up_params
    resource.errors.add(:recaptcha, "reCAPTCHA verification failed.")
    respond_with_navigational(resource) { render :new }
  end

  def generate_password
    params[:user] ||= {}
    params[:user][:password] = Devise.friendly_token.first(8)
  end

  def generate_welcome_email
    return unless current_user
    current_user.send_welcome_email_in_background(params[:user][:password])
  end
end
