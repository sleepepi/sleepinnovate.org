# frozen_string_literal: true

# Generates password and welcome email on registration.
class RegistrationsController < Devise::RegistrationsController
  prepend_before_action :generate_password, only: [:create]
  append_after_action :generate_welcome_email, only: [:create]

  layout "full_page"

  private

  def after_sign_up_path_for(resource)
    add_from_session(resource, :consented_at)
    add_from_session(resource, :clinic)
    session[:consented_at] = nil
    session[:enrollment] = nil
    profile_complete_path
  end

  def add_from_session(resource, key)
    resource.update key => session[key] if session[key].present?
  end

  def generate_password
    params[:user] ||= {}
    loop do
      params[:user][:password] = Devise.friendly_token
      # Make sure generated password is valid.
      u = User.new(password: params[:user][:password])
      u.validate
      break unless u.errors.attribute_names.include?(:password)
    end
  end

  def generate_welcome_email
    return unless current_user
    raw, enc = Devise.token_generator.generate(User, :reset_password_token)
    current_user.reset_password_token   = enc
    current_user.reset_password_sent_at = Time.now.utc + 42.hours
    current_user.save(validate: false)
    current_user.send_welcome_email_in_background(raw)
  end
end
