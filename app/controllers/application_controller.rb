# frozen_string_literal: true

# Main web application controller for website.
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  skip_before_action :verify_authenticity_token, if: :devise_login?
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :store_location

  def store_location
    if !request.post? && !request.xhr? && params[:format] != "atom"
      if internal_action?(params[:controller], params[:action])
        store_internal_location_in_session
      end
      if external_action?(params[:controller], params[:action])
        store_external_location_in_session
      end
    end
  end

  def after_sign_in_path_for(resource)
    session[:previous_internal_url] || session[:previous_external_url] || dashboard_path
  end

  def after_sign_out_path_for(resource_or_scope)
    session[:previous_external_url] || root_path
  end

  protected

  def internal_controllers
    {}
  end

  def internal_action?(controller, action)
    internal_controllers[controller.to_sym] && (
      internal_controllers[controller.to_sym].empty? ||
      internal_controllers[controller.to_sym].include?(action.to_sym)
    )
  end

  def external_controllers
    {}
  end

  def external_action?(controller, action)
    external_controllers[controller.to_sym] && (
      external_controllers[controller.to_sym].empty? ||
      external_controllers[controller.to_sym].include?(action.to_sym)
    )
  end

  def store_internal_location_in_session
    session[:previous_internal_url] = request.fullpath
  end

  def store_external_location_in_session
    session[:previous_external_url] = request.fullpath
    session[:previous_internal_url] = nil
  end

  def devise_login?
    params[:controller] == "devise/sessions" && params[:action] == "create"
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(
      :sign_up,
      keys: [:full_name, :email, :password] #  :password_confirmation
    )
  end
end
