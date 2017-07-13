# frozen_string_literal: true

# Defines a user in the web application.
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :omniauthable
  devise :confirmable, :database_authenticatable, :lockable, :registerable,
         :recoverable, :rememberable, :timeoutable, :trackable, :validatable

  # Concerns
  include Deletable
  include Forkable

  # Validations
  validates :full_name, presence: true

  # Methods

  def send_welcome_email_in_background(pw)
    fork_process(:send_welcome_email, pw)
  end

  def send_welcome_email(pw)
    RegistrationMailer.welcome_email(self, pw).deliver_now if EMAILS_ENABLED
  end
end
