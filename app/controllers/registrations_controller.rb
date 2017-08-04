# frozen_string_literal: true

# Adds a recaptcha on registration.
class RegistrationsController < Devise::RegistrationsController
  prepend_before_action :check_captcha, only: [:create]
  prepend_before_action :generate_password, only: [:create]
  append_after_action :generate_welcome_email, only: [:create]

  layout "full_page"

  private

  def after_sign_up_path_for(resource)
    consent_path
  end

  def check_captcha
    return unless RECAPTCHA_ENABLED && !verify_recaptcha
    self.resource = resource_class.new sign_up_params
    resource.errors.add(:recaptcha, "reCAPTCHA verification failed.")
    respond_with_navigational(resource) { render :new }
  end

  def verify_recaptcha
    url = URI.parse("https://www.google.com/recaptcha/api/siteverify")
    http = Net::HTTP.new(url.host, url.port)
    if url.scheme == "https"
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    post_params = [
      "secret=#{ENV['recaptcha_secret_key']}",
      "response=#{params['g-recaptcha-response']}",
      "remoteip=#{request.remote_ip}"
    ]
    response = http.start do |h|
      h.post(url.path, post_params.join("&"))
    end
    json = JSON.parse(response.body)
    json["success"]
  end

  def generate_password
    params[:user] ||= {}
    params[:user][:password] = Devise.friendly_token
    params[:user][:date_of_birth] = parse_date(params[:user][:date_of_birth], params[:user][:date_of_birth])
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
