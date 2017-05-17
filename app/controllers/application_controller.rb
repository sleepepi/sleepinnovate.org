# frozen_string_literal: true

# Main web application controller for website.
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  skip_before_action :verify_authenticity_token, if: :devise_login?
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def devise_login?
    params[:controller] == "devise/sessions" && params[:action] == "create"
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(
      :sign_up,
      keys: [:full_name, :email, :password, :password_confirmation]
    )
  end
end
